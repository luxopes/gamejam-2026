extends Node
## Hudba přítomnosti a minulosti. Obě stopy hrají dokola současně, slyšet je jen ta,
## která patří k aktuálnímu času (Game.time). Při změně času se plynule prolnou.
## Je to autoload, takže hudba po smrti a novém načtení úrovně nezačne od začátku.

@export var volume_db := 0.0     ## hlasitost hudby
@export var fade_time := 0.5     ## jak dlouho trvá prolnutí stop (s)

@onready var _tracks := {"present": $Present, "past": $Past}


func _ready() -> void:
	for time in _tracks:
		var player: AudioStreamPlayer = _tracks[time]
		player.volume_db = _db(1.0 if time == Game.time else 0.0)
		# Bez obrazovky (testy, kontrola z AGENTS.md) nehraje: nic by nebylo slyšet
		# a Godot by při ukončení hlásil nedohrané přehrávání jako chybu.
		if DisplayServer.get_name() != "headless":
			player.play()


func _process(delta: float) -> void:
	# Hlídá Game.time každý snímek: čas se mění portálem, ale i návratem na checkpoint
	for time in _tracks:
		var player: AudioStreamPlayer = _tracks[time]
		var target := 1.0 if time == Game.time else 0.0
		var level := move_toward(db_to_linear(player.volume_db - volume_db), target, delta / fade_time)
		player.volume_db = _db(level)


func _db(level: float) -> float:
	return volume_db + linear_to_db(maxf(level, 0.0001))
