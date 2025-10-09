extends CharacterBody3D

const SPEED = 10.0
const TURN_SPEED = 20.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var direction = Vector3.ZERO
var last_direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var plane_ref = Plane(Vector3.UP, Vector3.ZERO)
var cam_ref

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	var mouse_pos = get_viewport().get_mouse_position()
	var look_pos = plane_ref.intersects_ray(
		cam_ref.project_ray_origin(mouse_pos),
		cam_ref.project_ray_normal(mouse_pos)
	)
	if look_pos != null:
		$Armature/Skeleton3D/Turret.look_at(Vector3(
			look_pos.x,
			$Armature/Skeleton3D/Turret.global_position.y,
			look_pos.z))
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir:
		direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
		if velocity == Vector3.ZERO:
			velocity = last_direction.move_toward(direction * SPEED, delta * TURN_SPEED)
		else:
			velocity = velocity.move_toward(direction * SPEED, delta * TURN_SPEED)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, SPEED)
	if direction:
		if velocity != Vector3.ZERO:
			look_at(global_position + velocity)
			last_direction = velocity
	move_and_slide()
