extends Area2D

@export var target_time := "past"

func _on_body_entered(body: Node2D) -> void:
		if body.is_in_group("player"):
				Game.set_time(target_time)
