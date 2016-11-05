extends Control

const MAX_PLAYERS = 5

const PLAYER_COLORS = [
	Color(0x648623FF),
	Color(0x348CB8FF),
	Color(0xE699B4FF),
	Color(0xDB7F28FF),
	Color(0xDACAC7FF),
	Color(0xFEE76FFF),
	Color(0x4BD9D6FF),
	Color(0x632B6AFF),
	Color(0x810E0FFF)
]

var color_index = {}
var joined_game = {}

func _ready():
	set_process_input(true)
	# Set initial player color for all possible players
	for i in range(MAX_PLAYERS):
		color_index[i] = 0
		refresh_player_label(i)

func refresh_player_label(player_number):
	get_node("players/player%d" % player_number).set_color(get_player_color(player_number))
	
func get_player_color(player_number):
	return PLAYER_COLORS[color_index[player_number]]
	
func join_game(player_number):
	players.add_player(player_number, get_player_color(player_number))
	get_node("players/player%d" % player_number).set_opacity(0.4)
	joined_game[player_number] = true

func change_color(player_number, direction):
	color_index[player_number] = (color_index[player_number] + direction) % PLAYER_COLORS.size()
	refresh_player_label(player_number)
	
func has_joined_game(player_number):
	return joined_game.has(player_number)
	
func _input(event):
	for player_number in range(MAX_PLAYERS):
		if event.is_action_pressed("player%d_jump" % player_number):
			join_game(player_number)
		elif event.is_action_pressed("player%d_right" % player_number) and !has_joined_game(player_number):
			change_color(player_number, 1)
		elif event.is_action_pressed("player%d_left" % player_number) and !has_joined_game(player_number):
			change_color(player_number, -1)
	
	if players.get_players().size() > 0 and event.is_action_pressed("start_game"):
		get_tree().change_scene("res://scenes/game.tscn")
	
	if players.get_players().size() > 0:
		get_node("start_label").set_opacity(1.0)
