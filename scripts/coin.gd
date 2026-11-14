extends Area2D
## Sbírání mincí a efekt sebrání.

const FEEDBACK := preload("res://scenes/vfx/item_feedback.tscn")
const SOUND := preload("res://assets/sfx/coin.wav")


func _ready() -> void:
	if Game.is_coin_collected(self):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Game.add_coin(self)
		body.coin_collected()
		Vfx.spawn(FEEDBACK, get_parent(), global_position)
		Sfx.play(SOUND)
		queue_free()
