extends CanvasLayer

export(bool) var pause_on_unfocus = true

onready var overlay = get_node("pause_overlay")

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("pause"):
		if get_tree().is_paused():
			unpause()
		else:
			pause()
			
func _notification(what):
	# Pause game, when window loses focus
	if pause_on_unfocus and what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		pause()

func pause():
	get_tree().set_pause(true)
	overlay.show()
	
func unpause():
	get_tree().set_pause(false)
	overlay.hide()
