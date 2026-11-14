extends Area2D
## Jednoduchý statický nepřítel na testování útoku.
## Dotyk zabije hráče, po několika sekách zmizí. Je ve skupině "pogo".

@export var health := 3               ## kolik seků vydrží
@export var flash_time := 0.1         ## jak dlouho po zásahu bliká (s)

@onready var _body: ColorRect = $ColorRect
@onready var _color := _body.color


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()


## Volá hráč, když nepřítele sekne.
func hit(_direction: Vector2) -> void:
	health -= 1
	if health <= 0:
		queue_free()
		return
	_body.color = Color.WHITE
	await get_tree().create_timer(flash_time).timeout
	if is_instance_valid(self):
		_body.color = _color
