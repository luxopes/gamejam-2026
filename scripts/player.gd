extends CharacterBody2D
## Hráč. Všechna čísla níže jdou měnit v Inspektoru (klikni na uzel Player).

## Pro HUD: zavolá se při každé změně životů.
signal health_changed(health: int, max_health: int)

@export var speed := 300.0            ## rychlost běhu (px/s)
@export var acceleration := 2500.0    ## jak rychle se rozběhne a zastaví
@export var jump_velocity := -560.0   ## síla skoku (záporné = nahoru)
@export var gravity := 1300.0
@export var coyote_time := 0.1        ## jak dlouho po opuštění hrany jde ještě skočit
@export var jump_buffer := 0.1        ## jak dlouho před dopadem si hra pamatuje stisk skoku
@export var fall_limit_y := 1000.0    ## pod touto výškou hráč umírá

@export_group("Životy")
@export var max_health := 5
@export var invulnerable_time := 1.0  ## nezranitelnost po zásahu (s)
@export var hurt_knockback := Vector2(300.0, -350.0)  ## odhození po zásahu (do strany, nahoru)
@export var hurt_stun := 0.25         ## jak dlouho po zásahu nejde ovládat (s)

@export_group("Útok")
@export var attack_duration := 0.1    ## jak dlouho sek zasahuje (s)
@export var attack_cooldown := 0.35   ## pauza mezi seky (s)
@export var pogo_velocity := -520.0   ## odraz nahoru po seku dolů do bodáků/nepřítele
@export var recoil_speed := 260.0     ## odhození dozadu po seku do strany
@export var recoil_time := 0.12       ## jak dlouho odhození přebije ovládání (s)
@export var up_recoil := 150.0        ## sražení dolů po seku nahoru

@export_group("Dash")
@export var dash_speed := 900.0       ## rychlost dashe (px/s)
@export var dash_time := 0.18         ## jak dlouho dash trvá (s)
@export var dash_cooldown := 0.5      ## pauza mezi dashi (s)

@export_group("Rozhlížení")
@export var look_delay := 0.4         ## jak dlouho držet W/S, než se kamera pohne (s)
@export var look_distance := 180.0    ## o kolik se kamera posune nahoru/dolů (px)
@export var look_speed := 600.0       ## jak rychle kamera sjede (px/s)

@export_group("Efekty")
@export var landing_dust_speed := 400.0  ## od jaké rychlosti pádu se při dopadu zvedne prach (px/s)

const HIT_SPARK := preload("res://scenes/vfx/hit_spark.tscn")
const HURT_BURST := preload("res://scenes/vfx/hurt_burst.tscn")
const DASH_DUST := preload("res://scenes/vfx/dash_dust.tscn")
const DUST_PUFF := preload("res://scenes/vfx/dust_puff.tscn")

var _coyote := 0.0
var _buffer := 0.0
var _jumping := false   # true jen u normálního skoku, aby šlo zkrátit puštěním klávesy
var _facing := 1.0      # 1 = doprava, -1 = doleva
var _attack_timer := 0.0
var _cooldown_timer := 0.0
var _attack_dir := Vector2.RIGHT
var _already_hit: Array[Node] = []
var _recoil_timer := 0.0
var _dash_timer := 0.0
var _dash_cooldown_timer := 0.0
var _can_air_dash := true   # ve vzduchu jen jeden dash, obnoví ho dopad nebo pogo
var _dead := false
var _invulnerable_timer := 0.0
var _look_timer := 0.0

@onready var health := max_health
@onready var _hurtbox: Area2D = $Hurtbox

@onready var _attack_area: Area2D = $AttackArea
@onready var _slash: Vfx = $AttackArea/Slash
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	# Po smrti začíná hráč na posledním checkpointu
	var spawn = Game.get_checkpoint(owner)
	if spawn != null:
		global_position = spawn
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	_update_hurt(delta)
	if _dead:
		return
	_update_look(delta)
	if _update_dash(delta):
		return

	# Gravitace
	if is_on_floor():
		_coyote = coyote_time
		_can_air_dash = true
	else:
		_coyote -= delta
		velocity.y += gravity * delta
	if velocity.y >= 0.0:
		_jumping = false

	# Skok
	if Input.is_action_just_pressed("jump"):
		_buffer = jump_buffer
	else:
		_buffer -= delta
	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_buffer = 0.0
		_coyote = 0.0
		_jumping = true
		_spawn_vfx(DUST_PUFF, global_position)
	# Krátký stisk = nižší skok (pogo se tím nezkracuje)
	if Input.is_action_just_released("jump") and _jumping and velocity.y < 0.0:
		velocity.y *= 0.5
		_jumping = false

	# Pohyb do stran (během odhození po seku hráč neovládá)
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
	if is_on_floor() and not was_on_floor and fall_speed >= landing_dust_speed:
		_spawn_vfx(DUST_PUFF, global_position)

	if global_position.y > fall_limit_y:
		die()


func _update_attack(delta: float) -> void:
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		var attack_direction := Vector2.ZERO
		# Šipka spustí sek přímo ve svém směru, nezávisle na pohybu.
		if Input.is_action_just_pressed("attack_up"):
			attack_direction = Vector2.UP
		elif Input.is_action_just_pressed("attack_down"):
			attack_direction = Vector2.DOWN
		elif Input.is_action_just_pressed("attack_left"):
			attack_direction = Vector2.LEFT
		elif Input.is_action_just_pressed("attack_right"):
			attack_direction = Vector2.RIGHT
		if attack_direction != Vector2.ZERO:
			_start_attack(attack_direction)

	if _attack_timer > 0.0:
		_attack_timer -= delta
		_check_hits()


func _start_attack(direction: Vector2) -> void:
	_attack_dir = direction
	if direction.x != 0.0:
		_facing = direction.x
	_attack_area.rotation = _attack_dir.angle()
	_attack_timer = attack_duration
	_cooldown_timer = attack_cooldown
	_already_hit.clear()
	_slash.play()


func _check_hits() -> void:
	var targets: Array[Node] = []
	targets.append_array(_attack_area.get_overlapping_areas())
	targets.append_array(_attack_area.get_overlapping_bodies())
	for target in targets:
		if target == self or target in _already_hit:
			continue
		var hittable := target.has_method("hit")
		if not hittable and not target.is_in_group("pogo"):
			continue
		_already_hit.append(target)
		_spawn_vfx(HIT_SPARK, _attack_area.global_position + _attack_dir * 40.0)
		if hittable:
			target.hit(_attack_dir)
		_apply_hit_reaction()


## Odraz hráče po zásahu, jednou za sek.
func _apply_hit_reaction() -> void:
	if _already_hit.size() > 1:
		return
	match _attack_dir:
		Vector2.DOWN:
			# Pogo
			velocity.y = pogo_velocity
			_jumping = false
			_can_air_dash = true
		Vector2.UP:
			velocity.y = maxf(velocity.y, up_recoil)
		_:
			velocity.x = -_attack_dir.x * recoil_speed
			_recoil_timer = recoil_time


## Dash jako v Hollow Knight: rychle vodorovně, bez gravitace, pevná délka.
## Vrací true, dokud dash běží (pak se normální pohyb přeskočí).
func _update_dash(delta: float) -> bool:
	_dash_cooldown_timer -= delta
	if _dash_timer <= 0.0 and Input.is_action_just_pressed("dash") \
			and _dash_cooldown_timer <= 0.0 and (is_on_floor() or _can_air_dash):
		var direction := Input.get_axis("move_left", "move_right")
		if direction != 0.0:
			_facing = signf(direction)
		if is_on_floor():
			_spawn_vfx(DASH_DUST, global_position, -_facing)   # prach zůstává za hráčem
		else:
			_can_air_dash = false
		_dash_timer = dash_time
		_dash_cooldown_timer = dash_cooldown
		# Dash zruší rozběhnutý sek a skok
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
		# Na konci dashe prudce zpomalí na běžnou rychlost
		velocity.x = _facing * speed
		modulate = Color.WHITE
	if global_position.y > fall_limit_y:
		die()
	return true


## Rozhlížení jako v Hollow Knight: hráč stojí na zemi a drží W/S,
## po chvilce kamera sjede nahoru/dolů. Jakýkoli pohyb ji vrátí.
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
	_camera.offset.y = move_toward(_camera.offset.y, target, look_speed * delta)


## Zranění od čehokoli ve skupině "hurts_player" (bodáky, nepřátelé).
## Kontroluje se každý snímek, takže zraní i to, v čem hráč stojí po konci nezranitelnosti.
func _update_hurt(delta: float) -> void:
	if _invulnerable_timer > 0.0:
		_invulnerable_timer -= delta
		modulate.a = 0.3 if fmod(_invulnerable_timer, 0.2) < 0.1 else 1.0  # blikání
		if _invulnerable_timer <= 0.0:
			modulate.a = 1.0
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
	_spawn_vfx(HURT_BURST, global_position + Vector2(0, -24))
	if health == 0:
		die()
		return

	_invulnerable_timer = invulnerable_time
	# Odhodí hráče od zdroje zranění a na chvíli mu vezme ovládání
	var away := signf(global_position.x - from_position.x)
	if away == 0.0:
		away = -_facing
	velocity = Vector2(away * hurt_knockback.x, hurt_knockback.y)
	_recoil_timer = hurt_stun
	_dash_timer = 0.0
	modulate = Color.WHITE   # zásah utne dash, vrátí barvu z dashe
	_jumping = false


## Doplní životy (třeba na checkpointu).
func heal_full() -> void:
	health = max_health
	health_changed.emit(health, max_health)


## Vytvoří jednorázový efekt v úrovni (zůstane na místě, i když se hráč pohne).
## flip = -1 efekt zrcadlí.
func _spawn_vfx(scene: PackedScene, at: Vector2, flip := 1.0) -> void:
	var fx: Node2D = scene.instantiate()
	fx.scale.x *= flip
	get_parent().add_child(fx)
	fx.global_position = at


func die() -> void:
	if _dead:
		return
	_dead = true
	set_physics_process(false)   # hráč zamrzne, už se nedá ovládat

	var tween := create_tween()
	tween.set_parallel()         # obě změny běží současně
	tween.tween_property(self, "modulate:a", 0.0, 0.4)        # zprůhlední
	tween.tween_property(self, "scale", Vector2(1.8, 0.1), 0.4)  # rozplácne se
	await tween.finished

	Game.restart_level()
