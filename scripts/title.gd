extends Control
## Úvodní obrazovka: Enter nebo mezerník spustí hru od začátku.

@export_file("*.tscn") var first_level := "res://scenes/level_forest.tscn"


func _ready() -> void:
	Game.new_game()
	# Výzva ke startu bliká a rámeček s ovládáním pulzuje, ať si ho hráč všimne
	_pulse($Box/Start, 0.25, 0.5)
	_pulse($Box/Controls, 0.7, 0.9)


func _pulse(node: CanvasItem, low: float, time: float) -> void:
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "modulate:a", low, time)
	tween.tween_property(node, "modulate:a", 1.0, time)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file(first_level)
