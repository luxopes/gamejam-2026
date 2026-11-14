extends CharacterBody2D
## Nepřítel, který chodí tam a zpět. Po zásahu odletí, náraz do zdi ho zničí.
## Je ve skupině "hurts_player" (dotyk hráče zraní) a "pogo" (dá se od něj odrazit).

@export var walk_speed := 80.0          ## rychlost chůze (px/s)
@export var gravity := 1300.0
@export var health := 3                 ## kolik seků vydrží
@export var knockback_speed := 700.0    ## jak rychle odletí po zásahu (px/s)
@export var knockback_lift := 200.0     ## jak moc ho sek z boku nadhodí
@export var knockback_time := 0.35      ## jak dlouho letí, než zase chodí (s)
@export var flash_time := 0.15          ## jak dlouho po zásahu bliká (s)

var _direction := -1.0   # -1 = doleva, 1 = doprava
var _knockback_timer := 0.0
var _dead := false

@onready var _body: ColorRect = $ColorRect
@onready var _color := _body.color
@onready var _ledge_check: RayCast2D = $LedgeCheck


func _ready() -> void:
	# Hráč nepřítelem prochází, zraní ho jen dotyk (Hurtbox hráče)
	for player in get_tree().get_nodes_in_group("player"):
		add_collision_exception_with(player)
	_ledge_check.position.x = _direction * absf(_ledge_check.position.x)


func _physics_process(delta: float) -> void:
	if _dead:
		return
	if not is_on_floor():
		velocity.y += gravity * delta

	# Letí po zásahu: náraz do zdi nebo stropu ho zničí
	if _knockback_timer > 0.0:
		_knockback_timer -= delta
		move_and_slide()
		if is_on_wall() or is_on_ceiling():
			_destroy()
		return

	# Chůze tam a zpět: otočí se u zdi nebo na kraji plošiny
	if is_on_floor():
		_ledge_check.force_raycast_update()
		if is_on_wall() or not _ledge_check.is_colliding():
			_direction = -_direction
			_ledge_check.position.x = -_ledge_check.position.x
	velocity.x = _direction * walk_speed
	move_and_slide()


## Volá hráč, když nepřítele sekne. direction = směr seku.
func hit(direction: Vector2) -> void:
	if _dead:
		return
	health -= 1
	if health <= 0:
		_destroy()
		return

	if direction.x != 0.0:
		velocity = Vector2(direction.x * knockback_speed, -knockback_lift)
	else:
		velocity = direction * knockback_speed
	_knockback_timer = knockback_time

	_body.color = Color.WHITE
	create_tween().tween_property(_body, "color", _color, flash_time)


func _destroy() -> void:
	_dead = true
	collision_layer = 0           # sek ho už nenajde a hráče už nezraní

	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_property(self, "scale", Vector2(1.6, 0.2), 0.25)  # rozplácne se
	await tween.finished
	queue_free()
