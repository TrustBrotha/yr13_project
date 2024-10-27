extends Node
class_name State

# Defines variables used by all states
@export var can_move_state = true
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var character : CharacterBody3D
var next_state : State


# Process called from the physics process in the state controller
func state_process(delta):
	pass


# Controls input events while in each state
func state_input(event : InputEvent):
	pass


# Called once when entering the state
func on_enter():
	pass


# Called once when exiting the state
func on_exit():
	pass
