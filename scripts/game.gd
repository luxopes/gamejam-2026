extends Node
## Globální stav hry (autoload "Game" - je dostupný odkudkoli jako Game.neco).

signal coins_changed(count: int)
signal level_finished
signal time_changed(time: String)

var time := "present"

func set_time(new_time: String) -> void:
	time = new_time
	time_changed.emit(time)
	
var coins := 0

# Poslední checkpoint: ve které úrovni, kde a v jakém čase. Prázdné = začátek úrovně.
var _checkpoint_level := ""
var _checkpoint_position := Vector2.ZERO
var _checkpoint_time := "present"


func add_coin() -> void:
	coins += 1
	coins_changed.emit(coins)


## Zavolá checkpoint, když se ho hráč dotkne.
func set_checkpoint(level: Node, position: Vector2) -> void:
	_checkpoint_level = level.scene_file_path
	_checkpoint_position = position
	_checkpoint_time = time


## Kde se má hráč objevit, nebo null (pak zůstane na startu úrovně).
func get_checkpoint(level: Node) -> Variant:
	if level != null and level.scene_file_path == _checkpoint_level:
		return _checkpoint_position
	return null


## Zavolá se při smrti hráče nebo klávesou R. Hráč začne na posledním checkpointu.
func restart_level() -> void:
	# Vrátí i čas, ve kterém byl checkpoint, ať hráč nestojí ve vzduchu
	if get_checkpoint(get_tree().current_scene) != null:
		time = _checkpoint_time
	coins = 0
	get_tree().reload_current_scene.call_deferred()


## Zavolá cíl. Když je next_scene prázdné, hra končí výhrou.
func finish_level(next_scene: String) -> void:
	_checkpoint_level = ""
	if next_scene == "":
		level_finished.emit()
	else:
		coins = 0
		get_tree().change_scene_to_file.call_deferred(next_scene)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_level()
