extends Area2D
## Spouštěč v minulosti. Po zásahu sekem nastaví příznak a zmizí.

@export var flag := ""


func _ready() -> void:
		# Hádanka už je vyřešená (třeba po smrti hráče)
		if Game.has_flag(flag):
				queue_free()


func hit(_direction: Vector2) -> void:
		Game.set_flag(flag)
		queue_free()
