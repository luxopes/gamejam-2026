extends CharacterBody2D
## Hráč. Všechna čísla níže jdou měnit v Inspektoru (klikni na uzel Player).

@export var speed := 300.0            ## rychlost běhu (px/s)
@export var acceleration := 2500.0    ## jak rychle se rozběhne a zastaví
@export var jump_velocity := -560.0   ## síla skoku (záporné = nahoru)
@export var gravity := 1300.0
@export var coyote_time := 0.1        ## jak dlouho po opuštění hrany jde ještě skočit
@export var jump_buffer := 0.1        ## jak dlouho před dopadem si hra pamatuje stisk skoku
@export var fall_limit_y := 1000.0    ## pod touto výškou hráč umírá

var _coyote := 0.0
var _buffer := 0.0


func _physics_process(delta: float) -> void:
	# Gravitace
	if is_on_floor():
		_coyote = coyote_time
	else:
		_coyote -= delta
		velocity.y += gravity * delta

	# Skok
	if Input.is_action_just_pressed("jump"):
		_buffer = jump_buffer
	else:
		_buffer -= delta
	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_buffer = 0.0
		_coyote = 0.0
	# Krátký stisk = nižší skok
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

	# Pohyb do stran
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)

	move_and_slide()

	if global_position.y > fall_limit_y:
		die()


func die() -> void:
	Game.restart_level()
