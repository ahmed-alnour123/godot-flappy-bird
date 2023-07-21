extends Node2D

@export var pipes_scene: PackedScene
var pipe_margin = 300 # TODO: decrease it to make it harder
var can_instantiate = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_nodes_in_group("player")[0]
	player.died.connect(_on_player_died)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func instantiate_pipes() -> void:
	var height = get_viewport().size.y
	var instance = pipes_scene.instantiate() as Area2D
	$"../PipesPos".position.y = randi_range(pipe_margin, height)
	instance.position = $"../PipesPos".position
	add_child(instance)
	
func _on_pipes_timer_timeout() -> void:
	if not can_instantiate: return
	instantiate_pipes()
	
func _on_player_died() -> void:
	can_instantiate = false