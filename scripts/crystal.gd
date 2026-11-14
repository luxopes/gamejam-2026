extends Area2D
## Záblesk krystalu po zásahu.

func hit(_direction: Vector2) -> void:
	modulate = Color(2, 2, 2)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
