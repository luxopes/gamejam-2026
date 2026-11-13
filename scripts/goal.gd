extends Area2D
## Cíl úrovně.

## Další úroveň. Když zůstane prázdné, hra tady končí výhrou.
@export_file("*.tscn") var next_scene := ""


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_physics_process(false)
		Game.finish_level(next_scene)
