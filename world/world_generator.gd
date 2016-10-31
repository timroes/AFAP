extends Node2D

const repeat = 5
const GROUND_TILE_WIDTH = 128
const FLOOR_POSITION = GROUND_TILE_WIDTH / 2
const TILE = preload("res://world/ground/ground_tile.tscn")
const TREE = preload("res://world/plants/tree.tscn")
const BOX = preload("res://world/objects/box.tscn")

onready var camera = utils.get_camera()

var world_end = Vector2()

func _ready():
	set_process(true)
	# TODO: Fill first screen

func _process(delta):
	
	if rand_range(0, 100) <= 1:
		plant_tree()
	elif rand_range(0, 80) <= 1:
		boxes()

	if world_end.x <= camera.get_global_pos().x + camera.get_viewport_rect().size.width + GROUND_TILE_WIDTH:
		generate_next_tile()

func generate_next_tile():
	var new_tile = TILE.instance()
	new_tile.set_pos(Vector2(world_end.x, 0))
	add_child(new_tile)
	world_end.x += GROUND_TILE_WIDTH
	
func plant_tree():
	var tree = TREE.instance()
	tree.set_pos(Vector2(world_end.x, -FLOOR_POSITION))
	add_child(tree)
	
func boxes():
	var box = BOX.instance()
	box.set_pos(Vector2(world_end.x, -FLOOR_POSITION))
	add_child(box)
	pass