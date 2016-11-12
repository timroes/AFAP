extends KinematicBody2D

signal died(player_number)
signal picked_up_item(item)
signal used_item()

const GRAVITY = 1850.0

# The gravity with which a player slides down a wall
const WALL_SLIDE_GRAVITY = GRAVITY / 10

const JUMPING_START_VELOCITY = 880.0

# The maximum velocity a player can have while being in free fall
const MAX_FALLING_VELOCITY = 12000
# The maximum velocity a player can have while sliding down a wall
const MAX_WALL_SLIDE_VELOCITY = 100

const MAX_VELOCITY_X = 500

# The x-axis acceleration when the player moves right and left
const X_ACCELERATION = 2500
# The x-axis acceleration a player has in the air (usually slower, so
# that changing directions midair is slower, than on ground)
const X_ACCELERATION_AIR = X_ACCELERATION / 1

# The x-axis deceleration a player has on the ground, to prevent instant stopping
# if the player doesn't press right or left anymore
const X_DECELERATION_GROUND = 100000
# The x-axis deceleration a player has while being in air. This is usually less
# than on ground, because there is no "friction" in the air that a player would
# stop so suddenly.
const X_DECELERATION_AIR = 100

# The initial vector 
const WALLJUMP_START_VECTOR = Vector2(200, -800)
# The amount of seconds after a walljump that horizontal movement control should be frozen
const WALLJUMP_X_FREEZE_TIME = 0.15

# The velocity which a player will get when jumping onto another player
const HEADJUMP_BOUNCE_VELOCITY = 400
# The velocity to which the player that got headjumped will be set
const HEADJUMPED_PUSH_DOWN_VELOCITY = 350
# The time for which a headjumped player cannot do a wallslide
const HEADJUMPED_WALLSLIDE_FREEZE_TIME = 0.15

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
export(Color) var player_color = Color(1, 1, 1) setget set_player_color

onready var camera = utils.get_camera()
onready var point_of_death = get_node("point_of_death")
onready var sprite = get_node("sprite")

var gravity_direction = 1
var velocity = Vector2()

var state = STATE_IN_AIR setget set_state

var wall_slide_side
var x_movement_frozen = -1
var wallslide_frozen = -1

var controller_id

var action_jump
var action_left
var action_right
var action_item

var jump_pressed

var current_item

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	set_process(true)
	sprite.set_modulate(player_color)
	items.connect("gravity_changed", self, "gravity_changed")

func set_player_number(newval):
	player_number = newval
	action_jump = "player%d_jump" % player_number
	action_left = "player%d_left" % player_number
	action_right = "player%d_right" % player_number
	action_item = "player%d_item" % player_number
	
func set_player_color(newval):
	player_color = newval
	if sprite:
		sprite.set_modulate(newval)

func set_state(newval):
	if newval != state:
#		motion7.set_text("State: %s" % STATE_NAME_MAP[str(newval)])
		print("Changed player %d state to %s" % [player_number, STATE_NAME_MAP[str(newval)]])
		state = newval
		
func _input(event):
	if event.is_action_pressed(action_jump):
		jump_pressed = true
	if event.is_action_pressed(action_item):
		use_item()

# Toggle the gravity for this character and flip his sprite
func gravity_changed():
	gravity_direction *= -1
	sprite.set_flip_v(!sprite.is_flipped_v())

func die():
	# Disable input of this character, since it's dead now
	set_fixed_process(false)
	set_process_input(false)
	set_process(false)
	if controller_id != null:
		vibrator.player_death(controller_id)
	# TODO: die animation
	emit_signal("died", player_number)
	hide()
	queue_free()
	
func pickup_item():
	# If the player already holds an item, don't pick up another one
	if current_item != null:
		return false

	# Get a random item and send out pick up event
	current_item = items.get_random_item()
	emit_signal("picked_up_item", current_item)
	return true
	
func use_item():
	if current_item == null:
		return
	
	items.use_item(current_item, self)
	current_item = null
	emit_signal("used_item")

func _process(delta):
	if point_of_death.get_global_pos().x < camera.get_global_pos().x:
		die()

func _fixed_process(delta):
	var left_pressed = Input.is_action_pressed(action_left)
	var right_pressed = Input.is_action_pressed(action_right)
	
	if x_movement_frozen > 0:
		x_movement_frozen -= delta
		
	if wallslide_frozen > 0:
		wallslide_frozen -= delta
	
	if x_movement_frozen <= 0:
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
				velocity.y *= gravity_direction
				x_movement_frozen = WALLJUMP_X_FREEZE_TIME
			else:
				velocity.y = -gravity_direction * JUMPING_START_VELOCITY
			self.state = STATE_IN_AIR

	# Limit horizontal movement speed
	velocity.x = clamp(velocity.x, -MAX_VELOCITY_X, MAX_VELOCITY_X)
	
	if state == STATE_WALL_SLIDING and velocity.y > 0 and \
			wallslide_frozen <= 0 and \
			(wall_slide_side == -1 and right_pressed or \
			wall_slide_side == 1 and left_pressed):
		# If the user is currently wall sliding and presses towards the wall, fall slower (aka wall slide)
		velocity.y += gravity_direction * WALL_SLIDE_GRAVITY * delta
		velocity.y = clamp(-MAX_WALL_SLIDE_VELOCITY, velocity.y, MAX_WALL_SLIDE_VELOCITY)
	else:
		# Apply gravity in every tick
		velocity.y += gravity_direction * GRAVITY * delta
		velocity.y = clamp(-MAX_FALLING_VELOCITY, velocity.y, MAX_FALLING_VELOCITY)
	
	var motion = velocity * delta
	motion = move(motion)
	
	if is_colliding():
		
		var collider = get_collider()
		var norm = get_collision_normal()
		# gravity_direction + 1 * 90 will result in:
		# gravity_direction == -1 => 0°
		# gravity_direction == 1 => 180° 
		# which is basically just negating the required 180, if the gravity is negated
		var collided_from_above = vectors.points_towards(norm, (gravity_direction + 1) * 90)
	
		if collider.is_in_group("killing"):
			die()
		elif collider.is_in_group("player") and collided_from_above:
			headjump(collider)
			return
	
		motion = norm.slide(motion)
		velocity = norm.slide(velocity)
		motion = move(motion)

		if collided_from_above or (is_colliding() and vectors.points_towards(get_collision_normal(), (gravity_direction + 1) * 90)):
			# If either the first part of the movement or the slided part causes
			# a collision with the ground set the player state to on the ground.
			# It doesn't matter which part causes the collision, since we are still on the ground.
			self.state = STATE_ON_GROUND
		else:
			if collider.is_in_group("wallslide"):
				self.state = STATE_WALL_SLIDING
				wall_slide_side = sign(norm.x)
	 
	else:
		# If the player hasn't collided with anything after the regular move,
		# he must be in the air, since every other case would cause a collision
		# (e.g. the vertical movement due to gravity into the ground)
		self.state = STATE_IN_AIR
		
	jump_pressed = false
	
func headjump(other_player):
	# Bounce of the other player a bit
	velocity.y = -gravity_direction * HEADJUMP_BOUNCE_VELOCITY
	self.state = STATE_IN_AIR
	# TODO: Maybe make the downwawrds velocity of the headjumped player dependant on the jumpings
	# player y velocity.
	# Stop other players x velocity when jumping onto his head and give him some downwards velocity
	# (as long as he's not already moving downwards faster)
	other_player.velocity = Vector2(0, gravity_direction * max(abs(other_player.velocity.y), HEADJUMPED_PUSH_DOWN_VELOCITY))
	# Freeze other players wallslide for some time, so when he was wallsliding while being headjumped
	# he will fall for some time before able to slide again
	other_player.wallslide_frozen = HEADJUMPED_WALLSLIDE_FREEZE_TIME
	if other_player.controller_id != null:
		vibrator.player_headjumped(other_player.controller_id)