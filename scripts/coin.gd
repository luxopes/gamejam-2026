extends Area2D
## Mince. Po sebrání hráčem zmizí a přičte bod. Sebraná zůstane pryč i po smrti.


func _ready() -> void:
	if Game.is_coin_collected(self):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Game.add_coin(self)
		queue_free()
