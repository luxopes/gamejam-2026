extends Area2D
## Checkpoint ukládá místo návratu a jednou přidá životy.

@export var heal_amount := 1

const LEVER_UP := preload("res://assets/items/lever_up.png")
const STAR_BURST := preload("res://scenes/vfx/star_burst.tscn")
const HOLY_HEAL := preload("res://scenes/vfx/holy_heal.tscn")

var _healed := false
var _active := false

@onready var _lever: Sprite2D = $Lever


func _ready() -> void:
	# Návrat na checkpoint nesmí znovu přidat život.
	if Game.get_checkpoint(owner) == global_position:
		_lever.texture = LEVER_UP
		_active = true
		_healed = true


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	Game.set_checkpoint(owner, global_position)
	if not _active:
		_active = true
		_lever.texture = LEVER_UP
		Vfx.spawn(STAR_BURST, get_parent(), global_position + Vector2(0, -16))
	if not _healed:
		_healed = true
		if body.health < body.max_health:
			body.heal(heal_amount)
			Vfx.spawn(HOLY_HEAL, body, body.global_position)
