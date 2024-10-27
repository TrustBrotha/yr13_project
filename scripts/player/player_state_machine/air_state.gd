extends State

class_name air_state

# Accessed states
@export var ground_state_var : State
@export var dash_state_var : State
@export var block_state_var : State

# Controls how strong gravity is
var gravity_scale = 1
# Controls when player can jump while in the air
var can_jump = true


func state_process(delta):
	if character.velocity.y < 0:
		character.animation_tree.set("parameters/jump_and_fall/transition_request", "fall")
	
	# Apply gravity
	character.velocity.y -= gravity_scale * gravity * delta
	
	# Checks if on the ground
	if character.is_on_floor():
		next_state = ground_state_var


# Runs when entering state
func on_enter():
	character.animation_tree.set("parameters/state/transition_request", "air")
	# Sets can jump to true for coyote jump
	can_jump = true


func state_input(event : InputEvent):
	# Controls jump cases while in the air
	if event.is_action_pressed("ui_jump"):
		# If still in coyote time after falling off edge, player can still jump
		if can_jump:
			if character.velocity.y < 0:
				character.jump()
				can_jump = false
		
		# If not in coyote time, buffers jump
		# If jump buffered when hits the floor, jumps instantly (controlled in
		# Ground state)
		elif not can_jump:
			character.wants_to_jump = true
			character.timers.get_node("input_buffer_time").start()
	
	# Change in block_mode
	elif event.is_action_pressed("block"):
		next_state = block_state_var


func on_exit():
	pass


# Makes the player not able to jump after the coyote time runs out
func _on_coyote_timer_timeout():
	can_jump = false

