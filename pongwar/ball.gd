extends RigidBody2D

const SPEED = 300.0

var toggle : bool = false :
	set(val):
		toggle = val
		if toggle:
			$Sprite.modulate = Color.YELLOW
			collision_layer = 2
			collision_mask = 2
		else:
			$Sprite.modulate = Color.BLACK
			collision_layer = 1
			collision_mask = 1


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("tile"):
		body.toggle = !body.toggle
