extends Control

var player setget set_player

onready var player_name_label = get_node("player_name")
onready var item_icon = get_node("item_icon")

func set_player(new_player):
	player = new_player
	player_name_label.set_text("P%s" % [player.player_number + 1])
	player_name_label.add_color_override("font_color", player.player_color)
	player.connect("picked_up_item", self, "set_item")
	player.connect("used_item", self, "clear_item_icon")

func set_item(item):
	var icon = load("res://items/icons/%s.tex" % item.id)
	item_icon.set_texture(icon)
	print("Should set icon for ", item)
#	get_node("item_icon").

func clear_item_icon():
	item_icon.set_texture(null)
	print("Clear item icon")