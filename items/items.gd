extends Node

const ITEMS = [
	{ 'id': 'gravity_switch', 'name': "Gravity Switch" },
	{ 'id': 'old_school', 'name': "Old School", 'duration': 10.0, 'global_timer': true }
]

var global_timers = {}

func get_random_item():
	randomize()
	var item_index = randi() % ITEMS.size()
	return ITEMS[item_index]
	
func use_item(item, player):
	if self.has_method(item.id):
		self.call(item.id, player)
	
	if item.has('duration') and item.duration != null:
		var timer = Timer.new()
		timer.set_one_shot(true)
		timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
		timer.set_wait_time(item.duration)
		timer.connect("timeout", self, "_item_duration_end", [item, player], CONNECT_ONESHOT)
		timer.start()
		if item.has('global_duration') and item.global_duration:
			if global_timers.has(item.id):
				global_timers[item.id].stop()
				global_timers[item.id].queue_free()
			
			global_timers[item.id] = timer
		get_tree().get_current_scene().add_child(timer)

func _item_duration_end(item, player):
	var end_method = "%s_end" % item.id
	if self.has_method(end_method):
		self.call(end_method, player)

# -- Implementations for all items below this line --

# Gravity change item
signal gravity_changed
func gravity_switch(player):
	emit_signal("gravity_changed")
	
# Enable old school shader
func old_school(player):
	get_node("effects/old_school").show()
		
func old_school_end(player):
	get_node("effects/old_school").hide()