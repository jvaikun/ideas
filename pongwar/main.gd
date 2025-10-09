extends Node2D

const TILE_OBJ = preload("res://tile.tscn")
const TILE_SIZE = 16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tiles_width = get_viewport_rect().size.x / TILE_SIZE
	for i in tiles_width:
		for j in tiles_width:
			var tile_inst = TILE_OBJ.instantiate()
			$Tiles.add_child(tile_inst)
			tile_inst.position = Vector2(j * TILE_SIZE, i * TILE_SIZE)
			tile_inst.toggle = (j < tiles_width / 2)
	$Ball.toggle = false
	$Ball2.toggle = false
	$Ball3.toggle = true
	$Ball4.toggle = true
	$Ball.apply_impulse(Vector2.ONE * 400)
	$Ball2.apply_impulse(Vector2.ONE * 400)
	$Ball3.apply_impulse(-Vector2.ONE * 400)
	$Ball4.apply_impulse(-Vector2.ONE * 400)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
