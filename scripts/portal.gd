extends Area2D
## Portál do jiného času. Barva podle cíle: do minulosti teplá (oranžová),
## do přítomnosti studená (modrá), ať hráč hned pozná, kam vede.

@export var target_time := "past"

const WARM := Color(1.0, 0.72, 0.35)
const COLD := Color(0.45, 0.7, 1.0)


func _ready() -> void:
	var to_past := target_time == "past"
	var color := WARM if to_past else COLD
	$Sprite.play("to_past" if to_past else "to_present")
	$Glow.color = color
	$Sparks.color = color


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Game.set_time(target_time)
