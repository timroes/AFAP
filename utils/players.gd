extends Node

var players = []

func clear_players():
	players.clear()

func add_player(player_number, color):
	players.append({
		'number': player_number,
		'color': color
	})

func get_players():
	return players
