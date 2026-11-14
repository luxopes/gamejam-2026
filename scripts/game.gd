extends Node
## Globální stav hry (autoload "Game" - je dostupný odkudkoli jako Game.neco).

signal coins_changed(count: int)
signal level_finished
signal time_changed(time: String)
signal flag_changed(flag: String)

var time := "present"

func set_time(new_time: String) -> void:
	time = new_time
	time_changed.emit(time)
	
var coins := 0
var _collected_coins := {}   # sebrané mince, zůstávají i po smrti
var _new_game := false       # po výhře: R spustí hru znovu od začátku
var flags := {}

func set_flag(flag: String) -> void:
	flags[flag] = true
	flag_changed.emit(flag)


func has_flag(flag: String) -> bool:
	return flags.has(flag)


# Poslední checkpoint: ve které úrovni, kde a v jakém čase. Prázdné = začátek úrovně.
var _checkpoint_level := ""
var _checkpoint_position := Vector2.ZERO
var _checkpoint_time := "present"


func add_coin(coin: Node = null) -> void:
	coins += 1
	if coin:
		_collected_coins[_coin_id(coin)] = true
	coins_changed.emit(coins)


## Mince sebraná před smrtí se po novém načtení úrovně už neobjeví.
func is_coin_collected(coin: Node) -> bool:
	return _collected_coins.has(_coin_id(coin))


# Úroveň + cesta k minci ve scéně; po novém načtení úrovně zůstává stejná
func _coin_id(coin: Node) -> String:
	if coin.owner == null:
		return str(coin.get_path())
	return coin.owner.scene_file_path + ":" + str(coin.owner.get_path_to(coin))


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
	if _new_game:
		# Hrát znovu po výhře: mince od nuly a začátek v přítomnosti
		_new_game = false
		coins = 0
		time = "present"
	elif get_checkpoint(get_tree().current_scene) != null:
		# Vrátí i čas, ve kterém byl checkpoint, ať hráč nestojí ve vzduchu
		time = _checkpoint_time
	# Sebrané mince (počet i samotné mince) zůstávají i po smrti
	get_tree().reload_current_scene.call_deferred()


## Zavolá cíl. Když je next_scene prázdné, hra končí výhrou.
func finish_level(next_scene: String) -> void:
	flags.clear()
	_checkpoint_level = ""
	_collected_coins.clear()
	if next_scene == "":
		_new_game = true
		level_finished.emit()
	else:
		coins = 0
		get_tree().change_scene_to_file.call_deferred(next_scene)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_level()
