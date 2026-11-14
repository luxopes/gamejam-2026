extends Area2D
## Spouštěč v minulosti. Po zásahu sekem nastaví příznak.
## Balvan (flag "balvan", vytesaný kámen se sluncem) se po zásahu skutálí z římsy,
## výhonek u stromu po seku vykvete a zmizí. Dokud nejsou seknuté, třpytí se
## (Treasure Glint z PVFX Foundry) a jemně pulzují, aby hráč poznal, že se do nich dá seknout.

@export var flag := ""

const BLOOM := preload("res://scenes/vfx/bloom_heal.tscn")

var _pulse: Tween

@onready var _rock: Sprite2D = $Rock


func _ready() -> void:
	# Hádanka už je vyřešená (třeba po smrti hráče)
	if Game.has_flag(flag):
		queue_free()
		return
	_rock.visible = flag == "balvan"
	$Sprout.visible = not _rock.visible
	var look: Sprite2D = _rock if _rock.visible else $Sprout
	_pulse = create_tween().set_loops()
	_pulse.tween_property(look, "self_modulate", Color(1.6, 1.6, 1.3), 0.6).set_trans(Tween.TRANS_SINE)
	_pulse.tween_property(look, "self_modulate", Color.WHITE, 0.6).set_trans(Tween.TRANS_SINE)


func hit(direction: Vector2) -> void:
	if Game.has_flag(flag):
		return
	_pulse.kill()
	$Glint.queue_free()
	Game.set_flag(flag)
	$CollisionShape2D.set_deferred("disabled", true)
	if not _rock.visible:
		# Výhonek vykvete, strom v přítomnosti vyroste
		Vfx.spawn(BLOOM, get_parent(), global_position)
		queue_free()
		return
	# Balvan blikne a skutálí se ve směru seku dolů z římsy
	var side := -1.0 if direction.x < 0.0 else 1.0
	modulate = Color(2, 2, 2)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "position:x", position.x + side * 80.0, 0.7)
	tween.tween_property(self, "position:y", position.y + 240.0, 0.7) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(_rock, "rotation", side * TAU, 0.7)
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.4)
	tween.chain().tween_callback(queue_free)
