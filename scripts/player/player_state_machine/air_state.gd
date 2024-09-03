extends State

class_name air_state

# constants
const JUMP_VELOCITY = 10

#accessed states
@export var ground_state_var : State
@export var dash_state_var : State
@export var block_state_var : State

# controls how strong gravity is
var gravity_scale = 1
# controls when player can jump while in the air
var can_jump = true



func state_process(delta):
	# apply gravity
	character.velocity.y -= gravity_scale*gravity * delta
	
	#checks if on the ground
	if character.is_on_floor():
		next_state = ground_state_var
	
	# controls gliding (not sure if want to keep in)
	# only works when moving down
	if character.velocity.y < 0:
		if Input.is_action_pressed("ui_dash"):
			gravity_scale = 0.25
			character.sprite.rotation.x=+90
	if Input.is_action_just_released("ui_dash"):
		release_glide()
	




func on_enter():
	# sets can jump to true for coyote jump
	can_jump = true

func state_input(event : InputEvent):
	# controls jump cases while in the air
	if event.is_action_pressed("ui_jump"):
		# if still in coyote time after falling off edge, player can still jump
		if can_jump == true:
			if character.velocity.y < 0:
				character.velocity.y = JUMP_VELOCITY
				can_jump=false
		
		# if not in coyote time, buffers jump
		# if jump buffered when hits the floor, jumps instantly (controlled in
		# ground state)
		elif can_jump == false:
			character.wants_to_jump = true
			character.timers.get_node("input_buffer_time").start()
	
	
	elif event.is_action_pressed("block"):
		next_state = block_state_var


func on_exit():
	# resets before reaching ground
	release_glide()


func _on_coyote_timer_timeout():
	can_jump=false

func release_glide():
	gravity_scale = 1
	character.sprite.rotation.x=0


