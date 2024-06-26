extends State

class_name ground_state

const JUMP_VELOCITY = 10
@export var air_state_var : State
@export var dash_state_var : State

func state_process(delta):
	if not character.is_on_floor():
		next_state = air_state_var


func on_enter():
	pass

func state_input(event : InputEvent):
	if event.is_action_pressed("ui_jump"):
		character.velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("ui_dash"):
		if character.can_dash:
			next_state = dash_state_var



func on_exit():
	pass
