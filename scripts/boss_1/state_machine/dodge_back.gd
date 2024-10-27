extends State

# Accessed States
@export var idle_state_var : State


func on_enter():
	# Plays the dodging animation and makes the boss move back quickly
	character.animation_tree.set("parameters/state/transition_request","dodge_back")
	var vel = (character.transform.basis * Vector3(0, 0, -1)).normalized()*15
	character.velocity=vel
	await get_tree().create_timer(0.47).timeout
	next_state=idle_state_var
