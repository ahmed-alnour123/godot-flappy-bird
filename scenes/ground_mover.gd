extends Node2D

@onready var tile1 = $TileMap
@onready var tile2 = $TileMap2

var speed = 480.192
func _ready() -> void:
	get_tree().get_first_node_in_group("player").died.connect(func(): speed = 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tile1.translate(Vector2.LEFT * speed * delta)
	tile2.translate(Vector2.LEFT * speed * delta)
	
	for tile in [tile1, tile2]:
		if tile.position.x < -540:
			tile.position.x = 540
