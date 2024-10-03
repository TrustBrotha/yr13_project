extends State
@export var idle_state_var : State

func state_process(delta):
	if character.player_relative_location.length() > character.attack_range:
		next_state=idle_state_var
	
	print("reeeeee")
	character.velocity=Vector3.ZERO

func state_input(event : InputEvent):
	pass

func on_enter():
	character.animation_tree.set("parameters/state/transition_request","attack")

func on_exit():
	pass
