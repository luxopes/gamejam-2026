extends Area2D
## Checkpoint ukládá místo návratu a jednou přidá životy.

@export var active_color := Color(1.0, 0.85, 0.3)
@export var heal_amount := 1

var _healed := false

@onready var _flag: ColorRect = $Flag


func _ready() -> void:
	# Návrat na checkpoint nesmí znovu přidat život.
	if Game.get_checkpoint(owner) == global_position:
		_flag.color = active_color
		_healed = true


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Game.set_checkpoint(owner, global_position)
		if not _healed:
			_healed = true
			body.heal(heal_amount)
		_flag.color = active_color
