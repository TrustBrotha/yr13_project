extends State

class_name ground_state
# constants
const JUMP_VELOCITY = 10

# accessed states
@export var air_state_var : State
@export var dash_state_var : State
@export var block_state_var : State

func state_process(delta):
	# checks whether or not to switch to the air state
	if not character.is_on_floor():
		next_state = air_state_var


func on_enter():
	# if there is a jump buffered, execute the jump
	if character.wants_to_jump == true:
		character.velocity.y = JUMP_VELOCITY
		character.wants_to_jump = false


func state_input(event : InputEvent):
	# controls jumping
	if event.is_action_pressed("ui_jump"):
		character.velocity.y = JUMP_VELOCITY
	
	elif event.is_action_pressed("block"):
		next_state = block_state_var
	
	# controls dashing
	elif event.is_action_pressed("ui_dash"):
		if character.can_dash:
			next_state = dash_state_var
	
	



func on_exit():
	# starts the coyote time for falling off an edge
	if next_state == air_state_var:
		# input is length of coyote time
		character.timers.get_node("coyote_timer").start()
	
