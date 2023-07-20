extends Node2D

@export var pipes_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func instantiate_pipes() -> void:
	var instance = pipes_scene.instantiate() as Area2D
	$"../PipesPos".position.y = randi_range(200, 1780)
	instance.position = $"../PipesPos".position
	add_child(instance)
	


func _on_pipes_timer_timeout() -> void:
	instantiate_pipes()
