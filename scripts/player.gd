extends CharacterBody2D
## Pohyb, boj a kamera hráče.

signal health_changed(health: int, max_health: int)

@export var speed := 300.0
@export var acceleration := 2500.0
@export var jump_velocity := -560.0
@export var gravity := 1300.0
@export var coyote_time := 0.1
@export var jump_buffer := 0.1
@export var fall_limit_y := 1000.0

@export_group("Životy")
@export var max_health := 5
@export var coins_per_heal := 3
@export var invulnerable_time := 1.0
@export var hurt_knockback := Vector2(300.0, -350.0)
@export var hurt_stun := 0.25

@export_group("Útok")
@export var attack_duration := 0.1
@export var attack_cooldown := 0.35
@export var pogo_velocity := -520.0
@export var recoil_speed := 260.0
@export var recoil_time := 0.12
@export var up_recoil := 150.0
@export var vertical_attack_width := 32.0

@export_group("Dash")
@export var dash_speed := 900.0
@export var dash_time := 0.18
@export var dash_cooldown := 0.5

@export_group("Rozhlížení")
@export var look_delay := 0.4
@export var look_distance := 180.0
@export var look_speed := 600.0

@export_group("Efekty")
@export var landing_dust_speed := 400.0
@export var sprite_faces_left := false
@export var shake_strength := 4.0
@export var shake_time := 0.15
@export var hit_stop_time := 0.06
@export var jump_stretch := Vector2(0.8, 1.2)
@export var land_squash := Vector2(1.25, 0.8)
@export var land_squash_speed := 200.0
@export var squash_time := 0.15

const WALL_REACH := 64.0
const ATTACKS := {"attack_up": Vector2.UP, "attack_down": Vector2.DOWN,
		"attack_left": Vector2.LEFT, "attack_right": Vector2.RIGHT}
const HIT_SPARK := preload("res://scenes/vfx/hit_spark.tscn")
const HURT_BURST := preload("res://scenes/vfx/hurt_burst.tscn")
const DASH_DUST := preload("res://scenes/vfx/dash_dust.tscn")
const DUST_PUFF := preload("res://scenes/vfx/dust_puff.tscn")
const HOLY_HEAL := preload("res://scenes/vfx/holy_heal.tscn")
const JUMP_SOUND := preload("res://assets/sfx/jump.wav")
const SWORD_SOUND := preload("res://assets/sfx/sword.wav")

var _coyote := 0.0
var _buffer := 0.0
var _jumping := false
var _facing := 1.0
var _attack_timer := 0.0
var _cooldown_timer := 0.0
var _attack_dir := Vector2.RIGHT
var _already_hit: Array[Node] = []
var _recoiled := false
var _hit_wall := false
var _recoil_timer := 0.0
var _dash_timer := 0.0
var _dash_cooldown_timer := 0.0
var _can_air_dash := true
var _dead := false
var _invulnerable_timer := 0.0
var _look_timer := 0.0
var _look_offset := 0.0
var _shake_timer := 0.0
var _squash_tween: Tween

@onready var health := max_health
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _attack_area: Area2D = $AttackArea
@onready var _slash: Vfx = $AttackArea/Slash
@onready var _attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var _side_attack_size: Vector2 = _attack_shape.shape.size
@onready var _camera: Camera2D = $Camera2D
@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _sprite_scale: Vector2 = _sprite.scale


func _ready() -> void:
	var spawn = Game.get_checkpoint(owner)
	if spawn != null:
		global_position = spawn
	if Game.respawn_health > 0:
		health = Game.respawn_health
		Game.respawn_health = 0
	health_changed.emit(health, max_health)
	_coin_heal.call_deferred()


func _physics_process(delta: float) -> void:
	_update_hurt(delta)
	if _dead:
		return
	_update_look(delta)
	if _update_dash(delta):
		_update_animation()
		return

	if is_on_floor():
		_coyote = coyote_time
		_can_air_dash = true
	else:
		_coyote -= delta
		velocity.y += gravity * delta
	if velocity.y >= 0.0:
		_jumping = false

	if Input.is_action_just_pressed("jump"):
		_buffer = jump_buffer
	else:
		_buffer -= delta
	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_buffer = 0.0
		_coyote = 0.0
		_jumping = true
		Vfx.spawn(DUST_PUFF, get_parent(), global_position)
		Sfx.play(JUMP_SOUND, -8.0)
		_squash(jump_stretch)
	# Puštění klávesy zkrátí běžný skok, ne odraz od nepřítele.
	if Input.is_action_just_released("jump") and _jumping and velocity.y < 0.0:
		velocity.y *= 0.5
		_jumping = false

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0 and _attack_timer <= 0.0:
		_facing = signf(direction)
	_recoil_timer -= delta
	if _recoil_timer <= 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)

	_update_attack(delta)

	var fall_speed := velocity.y
	var was_on_floor := is_on_floor()
	move_and_slide()
	if is_on_floor() and not was_on_floor:
		if fall_speed >= landing_dust_speed:
			Vfx.spawn(DUST_PUFF, get_parent(), global_position)
		if fall_speed >= land_squash_speed:
			_squash(land_squash)

	if global_position.y > fall_limit_y:
		die()
	_update_animation()


func _update_attack(delta: float) -> void:
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		for action in ATTACKS:
			if Input.is_action_just_pressed(action):
				_start_attack(ATTACKS[action])
				break

	if _attack_timer > 0.0:
		_attack_timer -= delta
		_check_hits()


func _start_attack(direction: Vector2) -> void:
	_attack_dir = direction
	if direction.x != 0.0:
		_facing = direction.x
	_attack_area.rotation = _attack_dir.angle()
	_attack_shape.shape.size = _side_attack_size
	if direction.x == 0.0:
		_attack_shape.shape.size.y = vertical_attack_width
	_attack_timer = attack_duration
	_cooldown_timer = attack_cooldown
	_already_hit.clear()
	_recoiled = false
	_hit_wall = false
	_slash.play()
	Sfx.play(SWORD_SOUND, -8.0)


func _check_hits() -> void:
	# Area2D by v prvním snímku vracela dotyky předchozího seku.
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _attack_shape.shape
	query.transform = _attack_shape.global_transform
	query.collision_mask = _attack_area.collision_mask
	query.collide_with_areas = true
	query.exclude = [get_rid()]
	for found in get_world_2d().direct_space_state.intersect_shape(query, 32):
		var target: Node = found.collider
		if target in _already_hit:
			continue
		var hittable: bool = target.has_method("hit")
		if not hittable and not target.is_in_group("pogo"):
			continue
		_already_hit.append(target)
		Vfx.spawn(HIT_SPARK, get_parent(), _attack_area.global_position + _attack_dir * 40.0)
		_shake_timer = shake_time
		if hittable and target.is_in_group("hurts_player"):
			_hit_stop()
		if hittable:
			target.hit(_attack_dir)
		_apply_hit_reaction()

	if _attack_dir.x != 0.0 and not _hit_wall:
		# Paprsek ve výšce hrudi vynechá podlahu, o kterou oblast seku zavadí.
		var from := _attack_area.global_position
		var ray := PhysicsRayQueryParameters2D.create(from, from + _attack_dir * WALL_REACH, 1, [get_rid()])
		var wall := get_world_2d().direct_space_state.intersect_ray(ray)
		if wall and (wall.collider is StaticBody2D or wall.collider is TileMapLayer):
			_hit_wall = true
			Vfx.spawn(HIT_SPARK, get_parent(), wall.position)
			_apply_hit_reaction()


func _apply_hit_reaction() -> void:
	# Odraz platí jednou za sek, i když zasáhne víc cílů.
	if _recoiled:
		return
	_recoiled = true
	match _attack_dir:
		Vector2.DOWN:
			if is_on_floor():
				return
			velocity.y = pogo_velocity
			_squash(jump_stretch)
			_jumping = false
			_can_air_dash = true
		Vector2.UP:
			velocity.y = maxf(velocity.y, up_recoil)
		_:
			velocity.x = -_attack_dir.x * recoil_speed
			_recoil_timer = recoil_time


func _update_dash(delta: float) -> bool:
	_dash_cooldown_timer -= delta
	if _dash_timer <= 0.0 and Input.is_action_just_pressed("dash") \
			and _dash_cooldown_timer <= 0.0 and (is_on_floor() or _can_air_dash):
		var direction := Input.get_axis("move_left", "move_right")
		if direction != 0.0:
			_facing = signf(direction)
		if is_on_floor():
			Vfx.spawn(DASH_DUST, get_parent(), global_position, -_facing)
		else:
			_can_air_dash = false
		_dash_timer = dash_time
		_dash_cooldown_timer = dash_cooldown
		_attack_timer = 0.0
		_slash.stop()
		_recoil_timer = 0.0
		_jumping = false
		_buffer = 0.0
		modulate = Color(1.4, 1.4, 1.4)

	if _dash_timer <= 0.0:
		return false

	_dash_timer -= delta
	velocity = Vector2(_facing * dash_speed, 0.0)
	move_and_slide()
	if _dash_timer <= 0.0:
		velocity.x = _facing * speed
		modulate = Color.WHITE
	if global_position.y > fall_limit_y:
		die()
	return true


func _update_look(delta: float) -> void:
	var look := Input.get_axis("move_up", "move_down")
	var standing := is_on_floor() and absf(velocity.x) < 1.0 \
			and Input.get_axis("move_left", "move_right") == 0.0 \
			and _attack_timer <= 0.0 and _dash_timer <= 0.0
	if standing and look != 0.0:
		_look_timer += delta
	else:
		_look_timer = 0.0

	var target := 0.0
	if _look_timer >= look_delay:
		target = signf(look) * look_distance
	_look_offset = move_toward(_look_offset, target, look_speed * delta)

	var shake := Vector2.ZERO
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var strength := shake_strength * maxf(_shake_timer, 0.0) / shake_time
		shake = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
	_camera.offset = Vector2(0.0, _look_offset) + shake


func _hit_stop() -> void:
	if hit_stop_time <= 0.0 or Engine.time_scale == 0.0:
		return
	Engine.time_scale = 0.0
	# Časovač ignoruje time_scale a přežije zánik hráče.
	get_tree().create_timer(hit_stop_time, true, false, true).timeout.connect(
			Engine.set.bind("time_scale", 1.0))


func _squash(amount: Vector2) -> void:
	if _squash_tween:
		_squash_tween.kill()
	_sprite.scale = _sprite_scale * amount
	_squash_tween = create_tween()
	_squash_tween.tween_property(_sprite, "scale", _sprite_scale, squash_time) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _update_hurt(delta: float) -> void:
	if _invulnerable_timer > 0.0:
		_invulnerable_timer -= delta
		modulate.a = 0.3 if fmod(_invulnerable_timer, 0.2) < 0.1 else 1.0
		if _invulnerable_timer <= 0.0:
			modulate.a = 1.0
			_coin_heal()
		return

	var sources: Array[Node2D] = []
	sources.append_array(_hurtbox.get_overlapping_areas())
	sources.append_array(_hurtbox.get_overlapping_bodies())
	for source in sources:
		if source.is_in_group("hurts_player"):
			take_damage(1, source.global_position)
			return


func take_damage(amount: int, from_position: Vector2) -> void:
	if _dead or _invulnerable_timer > 0.0:
		return
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	Vfx.spawn(HURT_BURST, get_parent(), global_position + Vector2(0, -24))
	if health == 0:
		die()
		return

	_invulnerable_timer = invulnerable_time
	var away := signf(global_position.x - from_position.x)
	if away == 0.0:
		away = -_facing
	velocity = Vector2(away * hurt_knockback.x, hurt_knockback.y)
	_recoil_timer = hurt_stun
	_dash_timer = 0.0
	modulate = Color.WHITE
	_jumping = false


func shake() -> void:
	_shake_timer = shake_time


func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	health_changed.emit(health, max_health)


func coin_collected() -> void:
	_coin_heal()


func _coin_heal() -> void:
	if _dead or health >= max_health or Game.coins < coins_per_heal:
		return
	# Mince se utratí (zmizí z počítadla) až ve chvíli, kdy chybí život
	Game.spend_coins(coins_per_heal)
	heal(1)
	Vfx.spawn(HOLY_HEAL, self, global_position)   # efekt letí s hráčem


func _update_animation() -> void:
	var anim := "idle"
	if _dash_timer > 0.0:
		anim = "dash"
	elif not is_on_floor():
		anim = "jump" if velocity.y < 0.0 else "fall"
	elif absf(velocity.x) > 1.0:
		anim = "run"
	else:
		var look := Input.get_axis("move_up", "move_down")
		if look < 0.0:
			anim = "look_up"
		elif look > 0.0:
			anim = "look_down"
	_sprite.flip_h = (_facing > 0.0) == sprite_faces_left

	var frames := _sprite.sprite_frames
	if _slash.visible and _dash_timer <= 0.0:
		var attack := "attack"
		if _attack_dir.x == 0.0:
			attack = ATTACKS.find_key(_attack_dir)
		for name in [attack, "attack"]:
			if frames.has_animation(name):
				anim = name
				break
	if frames.has_animation(anim) and _sprite.animation != anim:
		_sprite.play(anim)


func die() -> void:
	if _dead:
		return
	_dead = true
	set_physics_process(false)
	Game.respawn_health = health

	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_property(self, "scale", Vector2(1.8, 0.1), 0.4)
	await tween.finished

	Game.restart_level()
