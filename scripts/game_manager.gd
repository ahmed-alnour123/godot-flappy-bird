class_name GameManager extends Node2D

var score = 0
@onready var player: Player = get_tree().get_first_node_in_group("player")

func add_score():
	score += 1
	print("score is %d" % score)

func _process(_delta) -> void:
	$HUD/Label.text = str(score)
