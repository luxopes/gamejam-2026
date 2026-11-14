extends Node
## Stav hry, checkpointy a přechody mezi scénami.

signal coins_changed(count: int)
signal level_finished
signal time_changed(time: String)
signal flag_changed(flag: String)

var time := "present"

func set_time(new_time: String) -> void:
	time = new_time
	time_changed.emit(time)


var coins := 0
var _collected_coins := {}
var _new_game := false
var restart_locked := false
# Nula znamená obnovení plných životů.
var respawn_health := 0
var flags := {}

func set_flag(flag: String) -> void:
	flags[flag] = true
	flag_changed.emit(flag)


func has_flag(flag: String) -> bool:
	return flags.has(flag)


var _checkpoint_level := ""
var _checkpoint_position := Vector2.ZERO
var _checkpoint_time := "present"


func add_coin(coin: Node) -> void:
	coins += 1
	_collected_coins[_coin_id(coin)] = true
	coins_changed.emit(coins)


## Utratí mince (třeba za uzdravení).
func spend_coins(amount: int) -> void:
	coins -= amount
	coins_changed.emit(coins)


func is_coin_collected(coin: Node) -> bool:
	return _collected_coins.has(_coin_id(coin))


# Cesta ve scéně zůstává po restartu stejná, instance uzlu ne.
func _coin_id(coin: Node) -> String:
	if coin.owner == null:
		return str(coin.get_path())
	return coin.owner.scene_file_path + ":" + str(coin.owner.get_path_to(coin))


func set_checkpoint(level: Node, position: Vector2) -> void:
	_checkpoint_level = level.scene_file_path
	_checkpoint_position = position
	_checkpoint_time = time


func get_checkpoint(level: Node) -> Variant:
	if level != null and level.scene_file_path == _checkpoint_level:
		return _checkpoint_position
	return null


func restart_level() -> void:
	if _new_game:
		new_game()
	elif get_checkpoint(get_tree().current_scene) != null:
		time = _checkpoint_time
	get_tree().reload_current_scene.call_deferred()


func new_game() -> void:
	coins = 0
	flags.clear()
	_collected_coins.clear()
	_checkpoint_level = ""
	_new_game = false
	restart_locked = false
	respawn_health = 0
	time = "present"


func finish_level(next_scene: String) -> void:
	flags.clear()
	_checkpoint_level = ""
	_collected_coins.clear()
	respawn_health = 0
	if next_scene == "":
		_new_game = true
		level_finished.emit()
	else:
		coins = 0
		get_tree().change_scene_to_file.call_deferred(next_scene)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and not restart_locked:
		var player := get_tree().get_first_node_in_group("player")
		if player:
			respawn_health = player.health
		restart_level()
