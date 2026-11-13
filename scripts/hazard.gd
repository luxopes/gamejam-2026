extends Area2D
## Past (bodáky). Dotyk = smrt a restart úrovně.


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
