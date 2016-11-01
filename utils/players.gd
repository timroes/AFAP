extends Node

var players = [1]

func clear_players():
	players.clear()

func add_player(player_number):
	players.append(player_number)

func get_players():
	return players
