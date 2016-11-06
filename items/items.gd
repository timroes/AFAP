extends Node

const ITEMS = [
	{ 'id': 'gravity_switch', 'name': "Gravity Switch" }
]

func get_random_item():
	randomize()
	var item_index = randi() % ITEMS.size()
	return ITEMS[item_index]
	
func use_item(item, player):
	if self.has_method(item.id):
		self.call(item.id, player)


# -- Implementations for all items below this line --

# Gravity change item
signal gravity_changed
func gravity_switch(player):
	emit_signal("gravity_changed")