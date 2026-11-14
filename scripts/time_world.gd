extends Node2D
## Zapínání přítomného a minulého světa.

func _ready() -> void:
	Game.time_changed.connect(_apply, CONNECT_DEFERRED)
	_apply(Game.time)

func _apply(time: String) -> void:
	_set_active($Present, time == "present")
	_set_active($Past, time == "past")

func _set_active(world: Node2D, active: bool) -> void:
	world.visible = active
	world.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	# Uspání uzlů nevypne kolize dlaždic.
	for layer in world.find_children("*", "TileMapLayer", true, false):
		layer.enabled = active
