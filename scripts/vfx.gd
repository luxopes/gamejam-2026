class_name Vfx
extends Sprite2D
## Efekt ze sprite sheetu (PVFX Foundry). Přehraje snímky a pak zmizí.
## Sheet má 8 sloupců, snímky jdou po řádcích zleva doprava.

@export var frame_count := 8
@export var fps := 12.5
@export var free_when_done := true  ## false = jen se skryje a jde spustit znovu (sek)
@export var loop := false  ## true = přehrává se pořád dokola (třpyt u hádankových věcí)

var _time := 0.0


func _ready() -> void:
	if free_when_done:
		play()
	else:
		stop()


## Spustí efekt od prvního snímku.
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
