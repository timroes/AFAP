extends Control

func _ready():
	set_process_input(true)
	
func _input(event):
	for player_number in range(4):
		if event.is_action_pressed("player%d_jump" % player_number):
			get_node("players/player%d" % player_number).set_opacity(1.0)
			players.add_player(player_number)
			
	if players.get_players().size() > 0 and event.is_action_pressed("start_game"):
		get_tree().change_scene("res://scenes/game.tscn")
	
	if players.get_players().size() > 0:
		get_node("start_label").set_opacity(1.0)
