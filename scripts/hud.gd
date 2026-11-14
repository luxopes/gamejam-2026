extends CanvasLayer
## Texty na obrazovce: počet mincí a hláška o výhře.


func _ready() -> void:
	Game.coins_changed.connect(_on_coins_changed)
	Game.level_finished.connect(_on_level_finished)
	_on_coins_changed(Game.coins)
	$Message.hide()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health, player.max_health)


func _on_coins_changed(count: int) -> void:
	$Coins.text = "Mince: %d" % count


func _on_level_finished() -> void:
	$Message.show()


func _on_health_changed(health: int, max_health: int) -> void:
	$Health.text = "Životy: %d/%d" % [health, max_health]
