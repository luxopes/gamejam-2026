extends Area2D
## Přechod mezi přítomností a minulostí.

@export var target_time := "past"

const WARM := Color(1.0, 0.72, 0.35)
const COLD := Color(0.45, 0.7, 1.0)
const REENTRY_DELAY_FRAMES := 5

# Sdílený limit brání okamžitému návratu portálem druhého světa.
static var _last_switch_frame := -REENTRY_DELAY_FRAMES


func _ready() -> void:
	var to_past := target_time == "past"
	var color := WARM if to_past else COLD
	$Sprite.play("to_past" if to_past else "to_present")
	$Glow.color = color
	$Sparks.color = color


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var frame := Engine.get_physics_frames()
	if frame - _last_switch_frame < REENTRY_DELAY_FRAMES:
		return
	_last_switch_frame = frame
	Game.set_time(target_time)
