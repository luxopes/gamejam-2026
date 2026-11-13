extends CanvasLayer
## Texty na obrazovce: počet mincí a hláška o výhře.


func _ready() -> void:
	Game.coins_changed.connect(_on_coins_changed)
	Game.level_finished.connect(_on_level_finished)
	_on_coins_changed(Game.coins)
	$Message.hide()


func _on_coins_changed(count: int) -> void:
	$Coins.text = "Mince: %d" % count


func _on_level_finished() -> void:
	$Message.show()
