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
	if event.is_action_pressed("pause"):
		get_tree().reload_current_scene()
