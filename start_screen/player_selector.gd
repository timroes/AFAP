extends Control

export(String) var name = "Player" setget set_name
export(Color) var color = Color(1,1,1) setget set_color

onready var name_label = get_node("player_name")

func _ready():
	name_label.set_text(name)
	name_label.add_color_override("font_color", color)

func set_color(newval):
	color = newval
	if name_label:
		name_label.add_color_override("font_color", newval)

func set_name(newval):
	name = newval
	if name_label:
		name_label.set_text(newval)
