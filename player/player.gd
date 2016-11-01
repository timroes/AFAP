extends KinematicBody2D

signal died(player_number)

const GRAVITY = 1450.0

# The gravity with which a player slides down a wall
const WALL_SLIDE_GRAVITY = GRAVITY / 10

const JUMPING_START_VELOCITY = 750.0
const JUMPING_ACCELERATION = 400.0

# The maximum velocity a player can have while being in free fall
const MAX_FALLING_VELOCITY = 12000
# The maximum velocity a player can have while sliding down a wall
const MAX_WALL_SLIDE_VELOCITY = 100

const MAX_VELOCITY_X = 500
const MIN_VELOCITY_X = -500

# The x-axis acceleration when the player moves right and left
const X_ACCELERATION = 2500
# The x-axis acceleration a player has in the air (usually slower, so
# that changing directions midair is slower, than on ground)
const X_ACCELERATION_AIR = X_ACCELERATION / 2.5

# The x-axis deceleration a player has on the ground, to prevent instant stopping
# if the player doesn't press right or left anymore
const X_DECELERATION_GROUND = 2000
# The x-axis deceleration a player has while being in air. This is usually less
# than on ground, because there is no "friction" in the air that a player would
# stop so suddenly.
const X_DECELERATION_AIR = 100

# The initial vector 
const WALLJUMP_START_VECTOR = Vector2(300, -600)
# The amount of seconds after a walljump that horizontal movement control should be froozen
const WALLJUMP_X_FREEZE_TIME = 0.15

const STATE_ON_GROUND = 0
const STATE_IN_AIR = 2
const STATE_WALL_SLIDING = 3

const STATE_NAME_MAP = {
	"0": "ON_GROUND",
	"1": "STARTING_JUMP",
	"2": "IN_AIR",
	"3": "WALL_SLIDING"
}

export(int) var player_number = 1 setget set_player_number

var velocity = Vector2()

var state = STATE_IN_AIR setget set_state

var wall_slide_side
var x_movement_froozen = -1

var action_jump
var action_left
var action_right

var jump_pressed

func _ready():
	set_fixed_process(true)
	set_process_input(true)

func set_player_number(newval):
	player_number = newval
	action_jump = "player%d_jump" % player_number
	action_left = "player%d_left" % player_number
	action_right = "player%d_right" % player_number

func set_state(newval):
	if newval != state:
		print("Changed player %d state to %s" % [player_number, STATE_NAME_MAP[str(newval)]])
		state = newval
		
func _input(event):
	if event.is_action_pressed(action_jump):
		jump_pressed = true

func die():
	# Disable input of this character, since it's dead now
	set_fixed_process(false)
	# TODO: die animation
	emit_signal("died", player_number)
	hide()
	
func _fixed_process(delta):
	var left_pressed = Input.is_action_pressed(action_left)
	var right_pressed = Input.is_action_pressed(action_right)
	
	if x_movement_froozen > 0:
		x_movement_froozen -= delta
	
	if x_movement_froozen <= 0:
		if right_pressed:
			if state == STATE_IN_AIR:
				velocity.x += X_ACCELERATION_AIR * delta
			else:
				velocity.x += X_ACCELERATION * delta
		elif left_pressed:
			if state == STATE_IN_AIR:
				velocity.x -= X_ACCELERATION_AIR * delta
			else:
				velocity.x -= X_ACCELERATION * delta
		else:
			if velocity.x != 0:
				if state == STATE_IN_AIR:
					velocity.x -= min(X_DECELERATION_AIR * delta, abs(velocity.x)) * sign(velocity.x)
				else:
					velocity.x -= min(X_DECELERATION_GROUND * delta, abs(velocity.x)) * sign(velocity.x)
	
	if state == STATE_ON_GROUND or state == STATE_WALL_SLIDING:
		if jump_pressed:
			if state == STATE_WALL_SLIDING:
				# Walljump
				velocity = WALLJUMP_START_VECTOR
				velocity.x *= wall_slide_side
				x_movement_froozen = WALLJUMP_X_FREEZE_TIME
			else:
				velocity.y = -JUMPING_START_VELOCITY
			self.state = STATE_IN_AIR

	# Limit horizontal movement speed
	velocity.x = clamp(velocity.x, MIN_VELOCITY_X, MAX_VELOCITY_X)
	
	if state == STATE_WALL_SLIDING and velocity.y > 0 and \
			(wall_slide_side == -1 and right_pressed or \
			wall_slide_side == 1 and left_pressed):
		# If the user is currently wall sliding and presses towards the wall, fall slower (aka wall slide)
		velocity.y += WALL_SLIDE_GRAVITY * delta
		velocity.y = min(velocity.y, MAX_WALL_SLIDE_VELOCITY)
	else:
		# Apply gravity in every tick
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALLING_VELOCITY)
	
	var motion = velocity * delta
	motion = move(motion)
	
	if is_colliding():
	
		if get_collider().is_in_group("killing"):
			die()
	
		var norm = get_collision_normal()
		var angle = abs(norm.angle() - PI)
		
		motion = norm.slide(motion)
		velocity = norm.slide(velocity)
		move(motion)
		
		if angle < 0.0001:
			self.state = STATE_ON_GROUND
		else:
			self.state = STATE_WALL_SLIDING
			wall_slide_side = sign(norm.x)
			
	jump_pressed = false
	