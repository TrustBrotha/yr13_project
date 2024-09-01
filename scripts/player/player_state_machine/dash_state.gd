extends State

class_name dash_state

# constants
const DASH_SPEED = 15
const DASH_ACCEL = 0.5

# accessed states
@export var air_state_var : State

# controls which way to roll
var dash_direction : Vector3
# controls the timing for when to start slowing down
var dashing = true

func state_process(delta):
	
	character.velocity.x = lerp(character.velocity.x,dash_direction.x*DASH_SPEED,DASH_ACCEL)
	character.velocity.z = lerp(character.velocity.z,dash_direction.z*DASH_SPEED,DASH_ACCEL)


func on_enter():
	character.get_last_direction()
	dash_direction = character.last_direction
	# starts timer to end dash
	character.timers.get_node("dash_time").start()
	# saves the last direction of the player, where direction is the
	# vector of the inputs
	


func state_input(event : InputEvent):
	pass


func on_exit():
	# starts dash cooldown
	character.can_dash = false
	character.timers.get_node("dash_cooldown").start()


# once finished dashing, switch to air state (easier than checking if in ground
# state or not)
func _on_dash_time_timeout():
	next_state = air_state_var
