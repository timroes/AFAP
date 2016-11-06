extends Area2D

func _on_item_body_enter(body):
	if body.has_method("pickup_item"):
		if body.pickup_item():
			hide()
			queue_free()
