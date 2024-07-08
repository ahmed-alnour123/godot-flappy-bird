extends Area2D

@export var speed = 480.192

var is_passed_player = false
@onready var game_manager: GameManager = $"/root/MainScene"
var player: Player
func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	player.died.connect(_on_player_died)
	# auto destroy
	await get_tree().create_timer(10).timeout
	if not player.is_dead:
		queue_free()


func _process(delta: float) -> void:
	var target_pos = position + (Vector2.LEFT * speed * delta)
	position = position.move_toward(target_pos, speed)
	
	if position.x < player.position.x and not is_passed_player:
		is_passed_player = true
		game_manager.add_score()

func _on_body_entered(body: Node2D) -> void:
	if not body == player: return
	player.die()
	
func _on_player_died() -> void:
	speed = 0
