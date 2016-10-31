extends Node

const SCROLL_SPEED = 150.0

onready var camera = get_node("camera")

var camera_pos = Vector2()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	camera_pos.x += delta * SCROLL_SPEED
	camera.set_pos(camera_pos)

func _input(event):
	if event.type == InputEvent.KEY and event.is_pressed() and event.scancode == KEY_R:
		get_tree().reload_current_scene()
	
