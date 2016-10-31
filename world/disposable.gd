extends Node2D

onready var camera = utils.get_camera()

# Must be the width of this and all children.
# Once this width has left the camera this object will be allowed to be freed.
export var disposable_width = 0

func _ready():
	set_process(true)
	
func _process(delta):
	if camera == null:
		return
		
	# Remove ground that went offscreen
	if get_global_pos().x + disposable_width < camera.get_global_pos().x:
		queue_free()
