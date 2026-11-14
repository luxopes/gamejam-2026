extends Control
## Úvodní obrazovka: Enter nebo mezerník spustí hru od začátku.

@export_file("*.tscn") var first_level := "res://scenes/level_forest.tscn"


func _ready() -> void:
	Game.new_game()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file(first_level)
