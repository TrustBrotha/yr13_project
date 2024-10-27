extends State

class_name ground_state

# Accessed states
@export var air_state_var : State
@export var dash_state_var : State
@export var block_state_var : State
@export var attack_state_var : State


func state_process(delta):
	# Checks whether or not to switch to the air state
	if not character.is_on_floor():
		next_state = air_state_var
	
	# If camera is in free mode, can either be in moving mode, or idle mode
	# Lerps to make transition between idle and moving smoother
	if character.cam_mode == "free":
		if character.moving:
			character.animation_tree.set(
				"parameters/walk_transition/blend_amount",
				lerp(character.animation_tree.get("parameters/walk_transition/blend_amount"),
				1.0,0.1))
		
		else:
			character.animation_tree.set(
				"parameters/walk_transition/blend_amount",
				lerp(character.animation_tree.get("parameters/walk_transition/blend_amount"),
				0.0,0.1))
	
	# If camera is locked on, has 2 blendspace2d options for running or walking.
	# The position in this 2d space controls how each movement animation blends together 
	elif character.cam_mode=="fixed":
		if character.running==true:
			character.animation_tree.set("parameters/walk_or_run_locked_on/transition_request","run")
			character.animation_tree.set(
				"parameters/locked_on_running/blend_position",
				lerp(character.animation_tree.get("parameters/locked_on_running/blend_position"),
				character.input_dir,0.1))
		else:
			character.animation_tree.set("parameters/walk_or_run_locked_on/transition_request","walk")
			character.animation_tree.set(
				"parameters/locked_on_walking/blend_position",
				lerp(character.animation_tree.get("parameters/locked_on_walking/blend_position"),
				character.input_dir,0.1))


func on_enter():
	# Sets animation state to ground
	character.animation_tree.set("parameters/state/transition_request","ground")
	# If there is a jump buffered, execute the jump
	if character.wants_to_jump == true:
		character.jump()
		character.wants_to_jump = false


func state_input(event : InputEvent):
	# Controls jumping
	if event.is_action_pressed("ui_jump"):
		character.jump()
	
	# Controls entering the block state
	elif event.is_action_pressed("block"):
		next_state = block_state_var
	
	# Controls dashing
	elif event.is_action_pressed("ui_dash"):
		if character.can_dash:
			next_state = dash_state_var
	
	# Controls attacking
	elif event.is_action_pressed("attack"):
		next_state = attack_state_var


func on_exit():
	# Starts the coyote time for falling off an edge
	if next_state == air_state_var:
		character.timers.get_node("coyote_timer").start()
