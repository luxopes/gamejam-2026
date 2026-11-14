extends Area2D
## Ostny zraňují hráče a ničí odmrštěné nepřátele.

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("kill"):
		body.kill()
