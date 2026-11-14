extends StaticBody2D
## Překážka v přítomnosti, která se změní podle příznaku z minulosti.

@export var flag := ""
@export var appears := false  ## false = po splnění zmizí (zával), true = objeví se (strom)


func _ready() -> void:
	Game.flag_changed.connect(_on_flag_changed)
	_update()


func _on_flag_changed(changed: String) -> void:
	if changed == flag:
		_update()


func _update() -> void:
	var active := Game.has_flag(flag) == appears
	visible = active
	$CollisionShape2D.set_deferred("disabled", not active)
