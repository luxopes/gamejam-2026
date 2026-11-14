extends CanvasLayer
## Závěrečné titulky; restart se povolí po jejich doběhnutí.

@export var fade_time := 1.0
@export var scroll_speed := 60.0

@onready var _back: ColorRect = $Back
@onready var _text: Label = $Text


func _ready() -> void:
	hide()
	Game.restart_locked = false
	Game.level_finished.connect(_roll)


func _roll() -> void:
	Game.restart_locked = true
	var screen := get_viewport().get_visible_rect().size
	_text.position.y = screen.y
	_back.modulate.a = 0.0
	show()
	# Poslední řádek titulků zůstane uprostřed obrazovky.
	var end_y := screen.y * 0.5 - _text.size.y + _text.get_line_height()
	var tween := create_tween()
	tween.tween_property(_back, "modulate:a", 1.0, fade_time)
	tween.parallel().tween_property(_text, "position:y", end_y, (screen.y - end_y) / scroll_speed)
	tween.tween_callback(func(): Game.restart_locked = false)
