extends Control

func add_player(player):
	var player_hud = get_node("player%d_hud" % player.player_number)
	player_hud.player = player
	player_hud.show()
