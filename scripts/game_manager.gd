class_name GameManager extends Node2D

var score = 0
var high_score = 0
@onready
var player: Player = get_tree().get_first_node_in_group("player")
@onready var spawner: PipesSpawner = $"PipesSpawner"
var game_started = false
const SCORE_FILE = "user://score_file.save"

func _ready() -> void:
	$MainMenu/MainMenu/Play.pressed.connect(start_game)
	$LosePanel/LosePanel/Play.pressed.connect(restart_game)
	player.died.connect(end_game)
	high_score = load_score()
	$LosePanel/LosePanel/Panel/VBoxContainer/BestScore.text = str(high_score)

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
	if score > high_score:
		save_score(score)
		$LosePanel/LosePanel/Panel/VBoxContainer/BestScore.text = str(score)
	$LosePanel.show()
	
	
func load_score() -> int:
	print("loading high score...")
	var score = 0
	if FileAccess.file_exists(SCORE_FILE):
		var line = FileAccess.open(SCORE_FILE, FileAccess.READ).get_line()
		score = int(line)
	print("hight score is ", score)
	return score
	
func save_score(score: int):
	print("saving high score...")
	var save_file = FileAccess.open(SCORE_FILE, FileAccess.WRITE)
	save_file.store_line(str(score))
	print("high score saved!!")
