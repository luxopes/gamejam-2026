extends CharacterBody2D
## Nepřítel (houba), který chodí tam a zpět. Po zásahu odletí, náraz do zdi ho zničí.
## Je ve skupině "hurts_player" (dotyk hráče zraní) a "pogo" (dá se od něj odrazit).

@export var walk_speed := 80.0          ## rychlost chůze (px/s)
@export var gravity := 1300.0
@export var health := 5                 ## kolik seků vydrží (stejně jako životy hráče)
@export var knockback_speed := 700.0    ## jak rychle odletí po zásahu (px/s)
@export var knockback_lift := 200.0     ## jak moc ho sek z boku nadhodí
@export var knockback_time := 0.35      ## jak dlouho letí, než zase chodí (s)
@export var sprite_faces_left := true   ## kam kouká houba ve sheetu
@export var fade_time := 0.3            ## jak rychle po animaci smrti zmizí (s)

var _direction := -1.0   # -1 = doleva, 1 = doprava
var _knockback_timer := 0.0
var _dead := false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _ledge_check: RayCast2D = $LedgeCheck


func _ready() -> void:
	# Hráč nepřítelem prochází, zraní ho jen dotyk (Hurtbox hráče)
	for player in get_tree().get_nodes_in_group("player"):
		add_collision_exception_with(player)
	_ledge_check.position.x = _direction * absf(_ledge_check.position.x)
	_face(_direction)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	# Mrtvý jen dopadne na zem a dohraje animaci smrti
	if _dead:
		velocity.x = 0.0
		move_and_slide()
		return

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
	_face(_direction)
	_sprite.play("run" if walk_speed > 0.0 else "idle")


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
		_face(-direction.x)   # kouká na hráče, který ho sekl
	else:
		velocity = direction * knockback_speed
	_knockback_timer = knockback_time
	_sprite.play("hit")
	_sprite.frame = 0


## Okamžitá smrt, třeba po pádu do ostnů.
func kill() -> void:
	if not _dead:
		_destroy()


func _destroy() -> void:
	_dead = true
	collision_layer = 0           # sek ho už nenajde a hráče už nezraní
	_sprite.play("die")
	await _sprite.animation_finished
	await create_tween().tween_property(self, "modulate:a", 0.0, fade_time).finished
	queue_free()


## Otočí sprite, aby houba koukala daným směrem (-1 doleva, 1 doprava).
func _face(dir: float) -> void:
	_sprite.flip_h = (dir > 0.0) == sprite_faces_left
