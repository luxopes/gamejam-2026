extends Area2D

## Po zásahu krystal krátce blikne.
func hit(_direction: Vector2) -> void:
	modulate = Color(2, 2, 2)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
