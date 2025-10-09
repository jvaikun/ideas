extends Node3D

const SENSITIVITY = 0.001
const SPEED = 30
const TURN_SPEED = 1

@onready var player = $Player


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Player movement
	var move = Input.get_axis("move_down", "move_up")
	player.velocity = Vector3.ZERO
	player.velocity += -player.transform.basis.z * move * SPEED
	player.move_and_slide()
	# Camera movement
	$Camera.global_position = $Player.global_position
	$Camera.rotation.y = $Player.rotation.y
	$Camera/Pitch.rotation.x = $Player.rotation.x


func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.rotate_y(-event.relative.x * SENSITIVITY)
		#player.rotate_x(event.relative.y * SENSITIVITY)
