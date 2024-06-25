extends State

class_name air_state

@export var ground_state_var : State
@export var dash_state_var : State
var gravity_scale = 1

func state_process(delta):
	character.velocity.y -= gravity_scale*gravity * delta
	if character.is_on_floor():
		next_state = ground_state_var
	
	if character.velocity.y < 0:
		if Input.is_action_pressed("ui_jump"):
			gravity_scale = 0.25
	if Input.is_action_just_released("ui_jump"):
		gravity_scale = 1


func on_enter():
	pass

func state_input(event : InputEvent):
	if Input.is_action_pressed("ui_dash"):
		next_state = dash_state_var
	


func on_exit():
	pass
