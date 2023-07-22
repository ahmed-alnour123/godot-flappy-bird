class_name Player extends RigidBody2D

signal died

@export var jump_power = 10.0
@onready var btn: TouchScreenButton = $"../TouchBtn"
var is_dead = false
var can_jump = false
@onready var original_pos = position.y

func _ready() -> void:
	btn.pressed.connect(jump)
	var ceiling = $"/root/MainScene/Ceiling" as Area2D
	ceiling.body_entered.connect(func(_body): can_jump = false)
	ceiling.body_exited.connect(func(_body): can_jump = true)

	gravity_scale = 0

func _process(delta: float) -> void:
	if not $"/root/MainScene".game_started:
		position.y = original_pos + sin(deg_to_rad(Time.get_ticks_msec() / 3)) * 30
		
	if Input.is_action_just_pressed("ui_accept"):
		jump()

func _physics_process(delta: float) -> void:
	var arc = 2000 - (-1000)
	rotation_degrees = (linear_velocity.y + 1000) / arc * (135) - 45

func jump() -> void:
	if is_dead or not can_jump: return
	
	linear_velocity = Vector2.ZERO
	if rotation_degrees > 0:
		rotation_degrees = 0
	apply_impulse(Vector2.UP * jump_power)


func _on_body_entered(body: Node) -> void:
	if body.name == "Ground":
		die()

		
func die() -> void:
	died.emit()
	is_dead = true
	linear_velocity.x = 0
	$AnimatedSprite2D.animation = "dead"
#	await get_tree().create_timer(5).timeout
#	get_tree().reload_current_scene()
	
	
