extends StaticBody2D
## Překážka ovládaná příznakem z minulosti.

@export var flag := ""
# true = po splnění se objeví, false = zmizí.
@export var appears := false
@export_enum("rocks", "trunk") var look := "rocks"
@export var height := 200.0

const TRUNK_WIDTH := 40.0
const ROCKS_WIDTH := 64.0
const TILES := preload("res://assets/levels/forest_tiles.tres")
const ROCK := preload("res://assets/levels/sunnyland/rock.png")
const ROCK_FILL := [138, 198, 137, 138]


func _ready() -> void:
	_build()
	Game.flag_changed.connect(_on_flag_changed)
	_update()


func _on_flag_changed(changed: String) -> void:
	if changed == flag:
		_update()


func _update() -> void:
	var active := Game.has_flag(flag) == appears
	visible = active
	$CollisionShape2D.set_deferred("disabled", not active)


func _build() -> void:
	var trunk := look == "trunk"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(TRUNK_WIDTH if trunk else ROCKS_WIDTH, height)
	$CollisionShape2D.shape = shape
	# Počátek překážky leží uprostřed spodní hrany.
	$CollisionShape2D.position = Vector2(0, -height / 2.0)

	var cols := 3 if trunk else 4
	var layer := TileMapLayer.new()
	layer.tile_set = TILES
	layer.collision_enabled = false
	layer.use_parent_material = true
	layer.position = Vector2(-cols * 8, -height)
	for y in ceili(height / 16.0):
		var ids := [127, ROCK_FILL[(3 + y * 5) % 4], ROCK_FILL[(6 + y * 5) % 4], 130]
		if trunk:
			ids = [67, 68, 70] if y == 0 else [207, 208 + (y % 2), 210]
		for x in cols:
			layer.set_cell(Vector2i(x, y), 0, Vector2i(ids[x] % 20, ids[x] / 20))
	add_child(layer)
	if trunk:
		return
	for side in [-1, 1]:
		var rock := Sprite2D.new()
		rock.texture = ROCK
		rock.use_parent_material = true
		rock.flip_h = side > 0
		rock.position = Vector2(side * (ROCKS_WIDTH / 2.0 + 6.0), -12.0)
		add_child(rock)
