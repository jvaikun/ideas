extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.cam_ref = $Camera/Pitch/Camera3D
