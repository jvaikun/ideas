extends StaticBody2D

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
