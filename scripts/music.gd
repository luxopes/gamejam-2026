extends Node
## Prolínání hudby přítomnosti a minulosti.

@export var volume_db := 0.0
@export var fade_time := 0.5

@onready var _tracks := {"present": $Present, "past": $Past}


func _ready() -> void:
	for time in _tracks:
		var player: AudioStreamPlayer = _tracks[time]
		player.volume_db = _db(1.0 if time == Game.time else 0.0)
		if DisplayServer.get_name() != "headless":
			player.play()


# Návrat na checkpoint mění čas i bez signálu time_changed.
func _process(delta: float) -> void:
	for time in _tracks:
		var player: AudioStreamPlayer = _tracks[time]
		var target := 1.0 if time == Game.time else 0.0
		var level := move_toward(db_to_linear(player.volume_db - volume_db), target, delta / fade_time)
		player.volume_db = _db(level)


func _db(level: float) -> float:
	return volume_db + linear_to_db(maxf(level, 0.0001))
