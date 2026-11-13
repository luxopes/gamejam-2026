extends Area2D
## Mince. Po sebrání hráčem zmizí a přičte bod.


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Game.add_coin()
		queue_free()
