extends StaticBody2D
## Překážka v přítomnosti, která se změní podle příznaku z minulosti.
## Pozice uzlu = střed spodní hrany, překážka roste nahoru o height.

@export var flag := ""
@export var appears := false  ## false = po splnění zmizí (zával), true = objeví se (strom)
## Vzhled: "rocks" = zával z kamenů, "trunk" = kmen stromu s pařezem nahoře
@export_enum("rocks", "trunk") var look := "rocks"
@export var height := 200.0  ## výška v px; zával má sahat až ke skále nad ním

const TRUNK_WIDTH := 40.0
const ROCKS_WIDTH := 64.0
const TILES := preload("res://assets/levels/forest_tiles.tres")
const ROCK := preload("res://assets/levels/sunnyland/rock.png")


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


## Kolize podle výšky a vzhled poskládaný z hotových assetů Sunnylandu
func _build() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(TRUNK_WIDTH if look == "trunk" else ROCKS_WIDTH, height)
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2(0, -height / 2.0)
	if look == "trunk":
		_build_trunk()
	else:
		_build_rocks()


func _build_trunk() -> void:
	# Kmen z dlaždic obřího stromu, 3 dlaždice široký, nahoře travnatý pařez
	var layer := TileMapLayer.new()
	layer.tile_set = TILES
	layer.collision_enabled = false
	layer.use_parent_material = true
	layer.position = Vector2(-24, -height)
	var rows := ceili(height / 16.0)
	for y in rows:
		var ids := [67, 68, 70] if y == 0 else [207, 208 + (y % 2), 210]
		for x in 3:
			layer.set_cell(Vector2i(x, y), 0, Vector2i(ids[x] % 20, ids[x] / 20))
	add_child(layer)


func _build_rocks() -> void:
	# Zával: kamenná zátka ze skalních dlaždic s balvany uvnitř, u paty suť z kamenů
	var layer := TileMapLayer.new()
	layer.tile_set = TILES
	layer.collision_enabled = false
	layer.use_parent_material = true
	var cols := int(ROCKS_WIDTH / 16.0)
	layer.position = Vector2(-ROCKS_WIDTH / 2.0, -height)
	var rows := ceili(height / 16.0)
	for y in rows:
		for x in cols:
			var id: int
			if x == 0:
				id = 127
			elif x == cols - 1:
				id = 130
			else:
				id = [138, 198, 137, 138][(x * 3 + y * 5) % 4]
			layer.set_cell(Vector2i(x, y), 0, Vector2i(id % 20, id / 20))
	add_child(layer)
	for side in [-1, 1]:
		var rock := Sprite2D.new()
		rock.texture = ROCK
		rock.use_parent_material = true
		rock.flip_h = side > 0
		rock.position = Vector2(side * (ROCKS_WIDTH / 2.0 + 6.0), -12.0)
		add_child(rock)
