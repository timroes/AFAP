extends Node

var players = []

func clear_players():
	players.clear()

func add_player(player_number, color, controller_id = null):
	players.append({
		'number': player_number,
		'color': color,
		'controller': controller_id
	})

func get_players():
	return players
