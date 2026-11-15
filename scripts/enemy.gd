extends CharacterBody2D
## Pohyb, zásahy a smrt nepřítele.

@export var walk_speed := 80.0
@export var gravity := 1300.0
@export var health := 5
@export var knockback_speed := 700.0
@export var knockback_lift := 200.0
@export var knockback_time := 0.35
@export var sprite_faces_left := true
@export var fade_time := 0.3

const DEATH_PUFF := preload("res://scenes/vfx/enemy_death.tscn")

var _direction := -1.0
var _knockback_timer := 0.0
var _dead := false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _ledge_check: RayCast2D = $LedgeCheck


func _ready() -> void:
	# Dotyk zraňuje přes Hurtbox; fyzická kolize by blokovala průchod.
	for player in get_tree().get_nodes_in_group("player"):
		add_collision_exception_with(player)
	_ledge_check.position.x = _direction * absf(_ledge_check.position.x)
	_face(_direction)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if _dead:
		velocity.x = 0.0
		move_and_slide()
		return

	if _knockback_timer > 0.0:
		_knockback_timer -= delta
		move_and_slide()
		if is_on_wall() or is_on_ceiling():
			_destroy()
		return

	if is_on_floor():
		_ledge_check.force_raycast_update()
		if is_on_wall() or not _ledge_check.is_colliding():
			_direction = -_direction
			_ledge_check.position.x = -_ledge_check.position.x
	velocity.x = _direction * walk_speed
	move_and_slide()
	_face(_direction)
	_sprite.play("run" if walk_speed > 0.0 else "idle")


func hit(direction: Vector2) -> void:
	if _dead:
		return
	health -= 1
	_flash()
	if health <= 0:
		_destroy()
		return

	if direction.x != 0.0:
		velocity = Vector2(direction.x * knockback_speed, -knockback_lift)
		_face(-direction.x)
	else:
		velocity = direction * knockback_speed
	_knockback_timer = knockback_time
	_sprite.play("hit")
	_sprite.frame = 0


func kill() -> void:
	if not _dead:
		_destroy()


func _destroy() -> void:
	_dead = true
	collision_layer = 0
	_sprite.play("die")
	await _sprite.animation_finished
	Vfx.spawn(DEATH_PUFF, get_parent(), global_position + Vector2(0, -20))
	await create_tween().tween_property(self, "modulate:a", 0.0, fade_time).finished
	queue_free()


# Krátké bílé probliknutí, ať je zásah vidět.
func _flash() -> void:
	_sprite.modulate = Color(3, 3, 3)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.15)


func _face(dir: float) -> void:
	_sprite.flip_h = (dir > 0.0) == sprite_faces_left
