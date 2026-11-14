extends Area2D
## Checkpoint. Po dotyku si hra pamatuje tohle místo, po smrti tu hráč začne.
## Taky přidá hráči život, každý checkpoint jen jednou za život (jinak by šlo
## chodit tam a zpátky a dobít se do plna).

@export var active_color := Color(1.0, 0.85, 0.3)  ## barva po aktivaci
@export var heal_amount := 1                        ## kolik životů přidá

var _healed := false

@onready var _flag: ColorRect = $Flag


func _ready() -> void:
	# Po návratu na tenhle checkpoint je rovnou aktivní a neléčí (hráč se na něm
	# objevil, jinak by si po pádu do jámy hned přidal život)
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
