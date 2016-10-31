extends KinematicBody2D

const GRAVITY = 1450.0
const JUMPING_START_VELOCITY = 600.0
const JUMPING_ACCELERATION = 400.0

const IDLE_VELOCITY_X = 0
const MAX_VELOCITY_X = 500
const MIN_VELOCITY_X = -500

const ACC_X_FASTER = 50
const ACC_X_SLOWER = 50

const WALLJUMP_START_VECTOR = Vector2(1000, 400)

const STATE_ON_GROUND = 0
const STATE_STARTING_JUMP = 1
const STATE_IN_AIR = 2
const STATE_WALL_SLIDING = 3

const STATE_NAME_MAP = {
	"0": "ON_GROUND",
	"1": "STARTING_JUMP",
	"2": "IN_AIR",
	"3": "WALL_SLIDING"
}

export var player_number = 1

var velocity = Vector2()

var state = STATE_IN_AIR setget set_state

var action_jump
var action_left
var action_right

func _ready():
	action_jump = "player%d_jump" % player_number
	action_left = "player%d_left" % player_number
	action_right = "player%d_right" % player_number
	velocity.x = IDLE_VELOCITY_X
	set_fixed_process(true)
	set_process_input(true)

func set_state(newval):
	if newval != state:
		print("Changed player %d state to %s" % [player_number, STATE_NAME_MAP[str(newval)]])
		state = newval
	
func _fixed_process(delta):
	var jump_pressed = Input.is_action_pressed(action_jump)
	var left_pressed = Input.is_action_pressed(action_left)
	var right_pressed = Input.is_action_pressed(action_right)
	
	if right_pressed:
		if state == STATE_IN_AIR:
			velocity.x += ACC_X_FASTER / 4
		else:
			velocity.x += ACC_X_FASTER
	elif left_pressed:
		if state == STATE_IN_AIR:
			velocity.x -= ACC_X_SLOWER / 4
		else:
			velocity.x -= ACC_X_SLOWER
	else:
		velocity.x = IDLE_VELOCITY_X
	
	if state == STATE_ON_GROUND or state == STATE_WALL_SLIDING:
		if jump_pressed:
			velocity.y = -JUMPING_START_VELOCITY
			if state == STATE_WALL_SLIDING:
				# Walljump
				velocity = get_collision_normal() * WALLJUMP_START_VECTOR
			self.state = STATE_IN_AIR
			
		
	velocity.x = clamp(velocity.x, MIN_VELOCITY_X, MAX_VELOCITY_X)
			
	if is_colliding():
		var coll_normal = get_collision_normal()
		if coll_normal.y == -1:
			self.state = STATE_ON_GROUND
			velocity.y = 0
		else:
			self.state = STATE_WALL_SLIDING
			velocity.y += GRAVITY * delta
	else:
		velocity.y += GRAVITY * delta
		
	move(velocity*delta)
