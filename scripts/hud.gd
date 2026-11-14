extends CanvasLayer
## Zobrazení životů a počtu mincí.

const HEARTS := preload("res://assets/ui/hearts.png")
const HEART_SIZE := Vector2(17, 15)
const HEART_SCALE := 3.0

@onready var _hearts: HBoxContainer = $Bar/Hearts
@onready var _coin_count: Label = $Bar/CoinRow/Count


func _ready() -> void:
	Game.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(Game.coins)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health, player.max_health)


func _on_coins_changed(count: int) -> void:
	_coin_count.text = str(count)


func _on_health_changed(health: int, max_health: int) -> void:
	while _hearts.get_child_count() < max_health:
		var heart := TextureRect.new()
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = HEART_SIZE * HEART_SCALE
		_hearts.add_child(heart)
	for i in _hearts.get_child_count():
		_hearts.get_child(i).texture = _heart(0 if i < health else 2)


func _heart(column: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = HEARTS
	texture.region = Rect2(Vector2(column * HEART_SIZE.x, 0), HEART_SIZE)
	return texture
