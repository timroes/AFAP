extends CanvasLayer

onready var overlay = get_node("pause_overlay")

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("pause"):
		if get_tree().is_paused():
			get_tree().set_pause(false)
			overlay.hide()
		else:
			get_tree().set_pause(true)
			overlay.show()
