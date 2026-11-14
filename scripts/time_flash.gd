extends CanvasLayer
## Záblesk při přechodu časem: když se změní čas (portál), obrazovka na chvilku zbělá.
## Je to autoload (Project Settings → Globals), takže funguje v každé úrovni.

@export var peak_alpha := 0.8    ## jak moc obrazovka zbělá (0–1)
@export var fade_in := 0.05      ## náběh záblesku (s)
@export var fade_out := 0.25     ## doznění (s)

var _tween: Tween

@onready var _rect: ColorRect = $ColorRect


func _ready() -> void:
	Game.time_changed.connect(_on_time_changed)


func _on_time_changed(_time: String) -> void:
	# Dva portály rychle za sebou: záblesk začne znovu, ne dva najednou
	if _tween:
		_tween.kill()
	_rect.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(_rect, "modulate:a", peak_alpha, fade_in)
	_tween.tween_property(_rect, "modulate:a", 0.0, fade_out)
