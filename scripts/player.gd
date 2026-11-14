extends CharacterBody2D
## Hráč. Všechna čísla níže jdou měnit v Inspektoru (klikni na uzel Player).

@export var speed := 300.0            ## rychlost běhu (px/s)
@export var acceleration := 2500.0    ## jak rychle se rozběhne a zastaví
@export var jump_velocity := -560.0   ## síla skoku (záporné = nahoru)
@export var gravity := 1300.0
@export var coyote_time := 0.1        ## jak dlouho po opuštění hrany jde ještě skočit
@export var jump_buffer := 0.1        ## jak dlouho před dopadem si hra pamatuje stisk skoku
@export var fall_limit_y := 1000.0    ## pod touto výškou hráč umírá

@export_group("Útok")
@export var attack_duration := 0.1    ## jak dlouho sek zasahuje (s)
@export var attack_cooldown := 0.35   ## pauza mezi seky (s)
@export var pogo_velocity := -520.0   ## odraz nahoru po seku dolů do bodáků/nepřítele
@export var recoil_speed := 260.0     ## odhození dozadu po seku do strany
@export var recoil_time := 0.12       ## jak dlouho odhození přebije ovládání (s)
@export var up_recoil := 150.0        ## sražení dolů po seku nahoru

var _coyote := 0.0
var _buffer := 0.0
var _jumping := false   # true jen u normálního skoku, aby šlo zkrátit puštěním klávesy
var _facing := 1.0      # 1 = doprava, -1 = doleva
var _attack_timer := 0.0
var _cooldown_timer := 0.0
var _attack_dir := Vector2.RIGHT
var _already_hit: Array[Node] = []
var _recoil_timer := 0.0

@onready var _attack_area: Area2D = $AttackArea
@onready var _slash: ColorRect = $AttackArea/Slash


func _ready() -> void:
	_slash.visible = false


func _physics_process(delta: float) -> void:
	# Gravitace
	if is_on_floor():
		_coyote = coyote_time
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

	move_and_slide()

	if global_position.y > fall_limit_y:
		die()


var _dead := false


func _update_attack(delta: float) -> void:
	_cooldown_timer -= delta
	if Input.is_action_just_pressed("attack") and _cooldown_timer <= 0.0:
		_start_attack()

	if _attack_timer > 0.0:
		_attack_timer -= delta
		_check_hits()
		if _attack_timer <= 0.0:
			_slash.visible = false


func _start_attack() -> void:
	# Směr: nahoru > dolů (jen ve vzduchu) > tam, kam hráč kouká
	if Input.is_action_pressed("move_up"):
		_attack_dir = Vector2.UP
	elif Input.is_action_pressed("move_down") and not is_on_floor():
		_attack_dir = Vector2.DOWN
	else:
		_attack_dir = Vector2(_facing, 0.0)

	_attack_area.rotation = _attack_dir.angle()
	_attack_timer = attack_duration
	_cooldown_timer = attack_cooldown
	_already_hit.clear()
	_slash.visible = true


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
		Vector2.UP:
			velocity.y = maxf(velocity.y, up_recoil)
		_:
			velocity.x = -_attack_dir.x * recoil_speed
			_recoil_timer = recoil_time


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
