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
	setup_about_dev_panel()
	connect_button_sounds()

func add_score():
	score += 1
	$LosePanel/LosePanel/Panel/VBoxContainer/Score.text = str(score)
	$Player/PipeAudioPlayer.play()


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
	await get_tree().create_timer(0.1).timeout
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

func setup_about_dev_panel():
	$MainMenu/MainMenu/About.pressed.connect(func(): $MainMenu/AboutDev.show())
	$MainMenu/AboutDev/Background/Panel/Exit.pressed.connect(func():$MainMenu/AboutDev.hide())
	$MainMenu/AboutDev/Background/Panel/Margin/Column/SocialMediaRow/Github/MarginContainer/TextureButton.pressed.connect(
		func(): OS.shell_open("https://github.com/ahmed-alnour123")
	)
	$MainMenu/AboutDev/Background/Panel/Margin/Column/SocialMediaRow/Twitter/MarginContainer/TextureButton.pressed.connect(
		func(): OS.shell_open("https://twitter.com/ahmedalnour123")
	)
	$MainMenu/AboutDev/Background/Panel/Margin/Column/SocialMediaRow/LinkedIn/MarginContainer/TextureButton.pressed.connect(
		func(): OS.shell_open("https://linkedin.com/in/ahmedalnour123/")
	)
	$MainMenu/AboutDev/Background/Panel/Margin/Column/SocialMediaRow/Discord/MarginContainer/TextureButton.pressed.connect(
		func(): OS.shell_open("mailto:ahmed2699@gmail.com")
	)

func goto_link(url: String):
	if OS.get_name() == "HTML5":
		JavaScriptBridge.eval("window.location.href='%s'" % url)
	else:
		OS.shell_open(url)

func _play_click_sound():
	$AudioPlayer.play()

func connect_button_sounds():
	$MainMenu/AboutDev/Background/Panel/Exit.pressed.connect(_play_click_sound)
	$MainMenu/MainMenu/About.pressed.connect(_play_click_sound)
	$MainMenu/MainMenu/Play.pressed.connect(_play_click_sound)
	$LosePanel/LosePanel/Play.pressed.connect(_play_click_sound)

