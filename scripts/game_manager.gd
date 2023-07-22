class_name GameManager extends Node2D

var score = 0
@onready
var player: Player = get_tree().get_first_node_in_group("player")
@onready var spawner: PipesSpawner = $"PipesSpawner"
var game_started = false

func _ready() -> void:
	$MainMenu/MainMenu/Play.pressed.connect(start_game)
	$LosePanel/LosePanel/Play.pressed.connect(restart_game)
	player.died.connect(end_game)

func add_score():
	score += 1
	$LosePanel/LosePanel/Panel/VBoxContainer/Score.text = str(score)

func _process(_delta) -> void:
	if not game_started: return
	
	$HUD/Label.text = str(score)

func start_game():
	$MainMenu.hide()
	player.can_jump = true
	player.gravity_scale = 2
	player.jump()
	spawner.can_instantiate = true
	game_started = true
	
func restart_game():
	get_tree().reload_current_scene()
	
func end_game():
	$LosePanel.show()
