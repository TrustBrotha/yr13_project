extends State

class_name dash_state

# Constants
const DASH_SPEED = 25
const DASH_ACCEL = 0.5

# Accessed states
@export var air_state_var : State
@export var ground_state_var : State

# Controls which way to roll
var dash_direction : Vector3
# Controls the timing for when to start slowing down
var dashing = true


# Accelerate player in dash direction
func state_process(delta):
	character.velocity.x = lerp(character.velocity.x, dash_direction.x * DASH_SPEED, DASH_ACCEL)
	character.velocity.z = lerp(character.velocity.z, dash_direction.z * DASH_SPEED, DASH_ACCEL)


func on_enter():
	# Control animation
	character.animation_tree.set("parameters/state/transition_request", "dash")
	# Saves dash direction
	dash_direction = character.last_direction
	# Covers edge case when locked on and not moving
	if character.cam_mode == "fixed" and character.direction == Vector3.ZERO:
		dash_direction = (character.cam_pivot_y.transform.basis * Vector3(0, 0, 1)).normalized()
	
	# Starts timer to end dash
	character.timers.get_node("dash_time").start()


func on_exit():
	# Starts dash cooldown
	character.can_dash = false
	character.timers.get_node("dash_cooldown").start()


# Once finished dashing, switch to next state
func _on_dash_time_timeout():
	if character.is_on_floor():
		next_state = ground_state_var
	else:
		next_state = air_state_var
