extends CanvasLayer

onready var overlay = get_node("end_overlay")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func show():
	set_process_input(true)
	overlay.show()
	
func _input(event):
	# TODO: Why doesn't this work for return button?
	if event.is_action_pressed("start_game"):
		get_tree().reload_current_scene()
		get_tree().set_input_as_handled()
