class_name Vfx
extends Sprite2D
## Přehrávání efektů ze sprite sheetů.

@export var frame_count := 8
@export var fps := 12.5
# false = efekt se jen skryje a lze ho spustit znovu.
@export var free_when_done := true
@export var loop := false

var _time := 0.0


static func spawn(scene: PackedScene, parent: Node, at: Vector2, flip := 1.0) -> void:
	var fx: Node2D = scene.instantiate()
	fx.scale.x *= flip
	parent.add_child(fx)
	fx.global_position = at


func _ready() -> void:
	if free_when_done:
		play()
	else:
		stop()


func play() -> void:
	_time = 0.0
	frame = 0
	show()
	set_process(true)


func stop() -> void:
	hide()
	set_process(false)


func _process(delta: float) -> void:
	_time += delta
	var next := int(_time * fps)
	if loop:
		frame = next % frame_count
	elif next < frame_count:
		frame = next
	elif free_when_done:
		queue_free()
	else:
		stop()
