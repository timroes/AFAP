extends Control

export(String) var name = "Player" setget set_name

onready var name_label = get_node("player_name")

func _ready():
	name_label.set_text(name)

func set_name(newval):
	name = newval
	if name_label:
		name_label.set_text(newval)
