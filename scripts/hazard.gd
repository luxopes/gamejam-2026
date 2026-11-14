extends Area2D
## Ostny: hráče zraní (skupina hurts_player), nepřítel, kterého do nich hráč odmrští, zemře.


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("kill"):
		body.kill()
