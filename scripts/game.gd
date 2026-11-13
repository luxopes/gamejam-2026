extends Node
## Globální stav hry (autoload "Game" - je dostupný odkudkoli jako Game.neco).

signal coins_changed(count: int)
signal level_finished

var coins := 0


func add_coin() -> void:
	coins += 1
	coins_changed.emit(coins)


## Zavolá se při smrti hráče nebo klávesou R.
func restart_level() -> void:
	coins = 0
	get_tree().reload_current_scene.call_deferred()


## Zavolá cíl. Když je next_scene prázdné, hra končí výhrou.
func finish_level(next_scene: String) -> void:
	if next_scene == "":
		level_finished.emit()
	else:
		coins = 0
		get_tree().change_scene_to_file.call_deferred(next_scene)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_level()
