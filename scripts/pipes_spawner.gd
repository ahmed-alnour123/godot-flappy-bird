class_name PipesSpawner extends Node2D

@export var pipes_scene: PackedScene
var pipe_margin = 300 # TODO: decrease it to make it harder
var can_instantiate = false

var next_pipe
var current_pipe
var first_pipe = true
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	player.died.connect(_on_player_died)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_pipe:
		if player.position.x > current_pipe.position.x + 200:
			current_pipe = next_pipe
		
	pass

func instantiate_pipes() -> void:
#	var height = get_viewport().size.y
	var height = 1920
	pipe_margin = height / 5
	var instance = pipes_scene.instantiate() as Area2D
	choose_random_pipe(instance)
	var new_pos = randi_range(pipe_margin, height - pipe_margin)
	$"../PipesPos".position.y = new_pos
	instance.position = $"../PipesPos".position
	add_child(instance)
	next_pipe = instance
	if first_pipe:
		current_pipe = next_pipe
		first_pipe = false
	
	

## choose a random pipe then delete the others
func choose_random_pipe(pipe: Node2D):
	var child_count = pipe.get_node("TopPipes").get_child_count()
	var choosen_pipe = randi_range(0, child_count - 1)
	for i in range(child_count):
		if i == choosen_pipe: continue
		pipe.get_node("TopPipes/" + str(i)).queue_free()
		pipe.get_node("BottomPipes/" + str(i)).queue_free()

func _on_pipes_timer_timeout() -> void:
	if not can_instantiate: return
	instantiate_pipes()
	
func _on_player_died() -> void:
	can_instantiate = false
