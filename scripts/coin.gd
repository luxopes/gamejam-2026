extends Area2D
## Mince (drahokam ze Sunny Land). Po sebrání hráčem zmizí, přičte bod a blikne efektem.
## Sebraná zůstane pryč i po smrti.

const FEEDBACK := preload("res://scenes/vfx/item_feedback.tscn")


func _ready() -> void:
	if Game.is_coin_collected(self):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Game.add_coin(self)
		var fx := FEEDBACK.instantiate()
		get_parent().add_child(fx)
		fx.global_position = global_position
		queue_free()
