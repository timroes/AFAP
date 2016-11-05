extends Node2D

# The pixel value of how far before the end of the world would scroll into view
# a new snippet is loaded.
const PRELOAD_HORIZON = 500

# The pixel value of how far a screen must be scrolled out of the visible view before it
# will be unloaded. Should at least be the size, that a player can partially leave the screen
# on the left before dying.
const UNLOAD_HORIZON = 100

var snippets = []
var snippet_count

var last_snippet_width

onready var camera = utils.get_camera()

var world_end = Vector2()

func _init():
	for scene in utils.get_scenes_in_directory("res://world/snippets"):
		var snippet = load(scene)
		snippets.append(snippet)
	snippet_count = snippets.size()

func _ready():
	set_process(true)

func _process(delta):
	if world_end.x <= camera.get_global_pos().x + camera.get_viewport_rect().size.width + PRELOAD_HORIZON:
		next_snippet()
	
	for i in range(get_child_count()):
		var child = get_child(i)
		if child.get_global_pos().x + child.snippet_width < camera.get_global_pos().x - UNLOAD_HORIZON:
			child.queue_free()

func next_snippet():
	randomize()
	var next_snippet_index = randi() % snippet_count
	var next_snippet = snippets[next_snippet_index]
	var snippet = next_snippet.instance()
	snippet.set_pos(Vector2(world_end.x, 0))
	world_end.x += snippet.snippet_width
	add_child(snippet)
	