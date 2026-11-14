extends CanvasLayer
## Záblesk obrazovky při změně času.

@export var peak_alpha := 0.8
@export var fade_in := 0.05
@export var fade_out := 0.25

const PORTAL_SOUND := preload("res://assets/sfx/portal.wav")

var _tween: Tween

@onready var _rect: ColorRect = $ColorRect


func _ready() -> void:
	Game.time_changed.connect(_on_time_changed)


func _on_time_changed(_time: String) -> void:
	Sfx.play(PORTAL_SOUND, -2.0)
	if _tween:
		_tween.kill()
	_rect.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(_rect, "modulate:a", peak_alpha, fade_in)
	_tween.tween_property(_rect, "modulate:a", 0.0, fade_out)
