extends Node

const SCROLL_SPEED = 150.0

const player = preload("res://player/player.tscn")

export(bool) var disable_scroll = false

onready var camera = get_node("camera")
onready var end_screen = get_node("end")

var camera_pos = Vector2()
var players_alive
var players_count

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	# Create players
	setup_players()


func setup_players():
	var ps = players.get_players()
	players_count = ps.size()
	players_alive = players_count
	for joined_player in ps:
		var p = player.instance()
		p.player_number = joined_player.number
		p.player_color = joined_player.color
		p.set_pos(Vector2(500 + 100*joined_player.number, 200))
		p.connect("died", self, "player_died")
		add_child(p)

func player_died(player_number):
	players_alive -= 1
	if players_count > 1 and players_alive == 1 \
			or players_count == 1 and players_alive == 0:
		end_game()

func end_game():
	get_tree().set_pause(true)
	end_screen.show()

func _fixed_process(delta):
	if not disable_scroll:
		camera_pos.x += delta * SCROLL_SPEED
		camera.set_pos(camera_pos)

