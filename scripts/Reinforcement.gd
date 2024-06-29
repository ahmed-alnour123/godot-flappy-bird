extends Node

@onready var socket : SocketConnection = $Socket
@onready var player : Player = $"../MainScene/Player"
@onready var pipe_spawner:PipesSpawner = $"../MainScene/PipesSpawner"
@onready var game_manager :GameManager = $"../MainScene"
@export var is_done:bool = false
var just_added_score = false
var end_learn = false
var pipe_gate_width = 130

# Called when the node enters the scene tree for the first time.
func _ready():
	socket.message_recieved.connect(on_message_recieved)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_E):
		end_learn = true
	#if $"../MainScene/Player" and $"../MainScene/Player".is_dead:
		#print($"../MainScene/Player".position.x -$"../MainScene/PipesSpawner".current_pipe.position.x)
	if $"../MainScene/Player" :
		is_done = $"../MainScene/Player".is_dead
	
	

func on_client_connected():
	print("client connected")


func on_message_recieved(message):
	if end_learn:
		socket.send_json({'code':3})
		
	var res = JSON.parse_string(message)
	if res['code'] == 0:
		$"../MainScene".start_game()
		send_initial_state()

	if res['code'] == 1:
		var reward = play_frame(res['action'])
		send_current_state(reward)

	if res['code'] == 2:
		#print(message)
		$"../MainScene".restart_game()
		await get_tree().create_timer(1).timeout
		$"../MainScene".start_game()
		send_initial_state()


func play_frame(action) -> int:
	#print(action)
	player = $"../MainScene/Player"
	pipe_spawner = $"../MainScene/PipesSpawner"
	var reward = 0
	if player.can_jump and action == 1:
			player.jump()
			#reward = 1
	if player.is_dead:
		
		is_done = true
		#if player.position.x 
		if player.died_from_pipe:
			#reward = -3 * abs(player.position.y - pipe_spawner.current_pipe.position.y)
			reward = -8000
		else:
			reward = -8000
	if just_added_score:
		reward += 500
		just_added_score = false
	if pipe_spawner.current_pipe:
		if (player.position.y > pipe_spawner.current_pipe.position.y -40 and player.position.y < pipe_spawner.current_pipe.position.y +80):
			pass
			#reward += 10
		else:
			pass
			#reward -= 10
	if reward != 0:
		print("Gained: ",reward)
	return reward

func send_initial_state():

	var data = {
	'code':1,
	'state':[1400,960-pipe_gate_width,960+pipe_gate_width,0],
	'is_done':0,
	'reward':0
	}

	socket.send_json(data)

func send_current_state(reward):
	var done_val
	if is_done:
		done_val = 1
	else:
		done_val = 0
		
	pipe_spawner = $"../MainScene/PipesSpawner"
	var pipe_pos
	if pipe_spawner.current_pipe:
		pipe_pos = pipe_spawner.current_pipe.position
	else:
		pipe_pos = Vector3(1400,960,0)
		
	player = $"../MainScene/Player"
	var player_pos
	var player_velocity
	if player :
		player_pos = player.position.y
		player_velocity = player.linear_velocity.y
	else:
		player_velocity = 0
		player_pos = 937
		
	var data = {
	'code':1,
	'state':[pipe_pos.x,pipe_pos.y-pipe_gate_width-player.position.y,pipe_pos.y+pipe_gate_width-player.position.y,player_velocity],
	'done_val':done_val,
	'reward':reward
	}

	
	socket.send_json(data)
