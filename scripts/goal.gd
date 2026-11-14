extends Area2D
## Cíl úrovně: truhla ze Sunny Land. Zavřená se třpytí, po dotyku hráče se se zvukem otevře.

## Další úroveň. Když zůstane prázdné, hra tady končí výhrou.
@export_file("*.tscn") var next_scene := ""

const FEEDBACK := preload("res://scenes/vfx/item_feedback.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_physics_process(false)
		$Chest.frame = 1
		$OpenSound.play()
		$Glint.queue_free()
		Vfx.spawn(FEEDBACK, get_parent(), global_position + Vector2(0, -20))
		Game.finish_level(next_scene)
