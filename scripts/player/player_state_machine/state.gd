extends Node
class_name State

@export var can_move_state = true
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var character : CharacterBody3D
var next_state : State


func state_process(delta):
	pass


func state_input(event : InputEvent):
	pass


func on_enter():
	pass


func on_exit():
	pass
