@tool
extends StaticBody2D
## Plošina s nastavitelnou velikostí. Počátek leží v levém horním rohu.

@export var size := Vector2(200, 30):
	set(value):
		size = value
		_update()

@export var color := Color(0.29, 0.48, 0.23):
	set(value):
		color = value
		_update()


func _ready() -> void:
	_update()


func _update() -> void:
	if not is_node_ready():
		return
	$ColorRect.size = size
	$ColorRect.color = color
	var shape := RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = size / 2.0
