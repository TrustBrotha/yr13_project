extends Node
class_name State

@export var can_move_state = true
var character : CharacterBody2D
var next_state : State



# defines states in "state" class
func state_process(delta):
	pass

func state_input(event : InputEvent):
	pass

func on_enter():
	pass

func on_exit():
	pass
