extends RigidBody2D

@export var jump_power = 10.0
@onready var btn: TouchScreenButton = $"../TouchBtn"

func _ready() -> void:
	btn.pressed.connect(on_button_pressed)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		on_button_pressed()
	var arc = 2000 - (-1000)
	rotation_degrees = (linear_velocity.y + 1000) / arc * (135) - 45

func on_button_pressed() -> void:
	linear_velocity = Vector2.ZERO
	if rotation_degrees > 0:
		rotation_degrees = 0
	apply_impulse(Vector2.UP * jump_power)

