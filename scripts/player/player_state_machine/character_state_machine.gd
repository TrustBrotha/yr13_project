extends Node

class_name CharacterStateMachine
@export var character : CharacterBody3D
@export var current_state : State
var states = [State]


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if(child is State):
			states.append(child)
			child.character = character
			#set up states
			
		else:
			push_warning("child" + child.name + "not a state for character state machine")


# controls which state is being accessed, runs its process
func _physics_process(delta):
	if(current_state.next_state != null):
		switch_states(current_state.next_state)
	
	current_state.state_process(delta)


# checks if the player can move while in each state
func check_if_can_move():
	return current_state.can_move_state


# controls on exit and on enter functions for states
func switch_states(new_state : State):
	if(current_state != null):
		current_state.on_exit()
		current_state.next_state = null
	
	current_state = new_state
	current_state.on_enter()


# calls input functions from state machine
func _input(event):
	current_state.state_input(event)
