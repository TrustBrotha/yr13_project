extends State

@export var ground_state_var : State
@export var air_state_var : State
@export var parry_timer : Timer
var want_to_switch_state=false
var can_switch_state=false

var parry_times=[0.2,0.15,0.1,0.05,0.01]


func state_process(delta):
	# Adds gravity
	character.velocity.y -= gravity * delta
	
	# Decellerates player if on the ground
	if character.is_on_floor():
		character.velocity.x = lerp(character.velocity.x,0.0,character.ACCELERATION*delta)
		character.velocity.z = lerp(character.velocity.z,0.0,character.ACCELERATION*delta)
	
	# If the player wants to leave the block state and they can, switch state.
	if want_to_switch_state and can_switch_state:
		if character.is_on_floor():
			next_state=ground_state_var
		else:
			next_state=air_state_var


func state_input(event : InputEvent):
	# Controls when the player wants to leave
	if event.is_action_released("block"):
		want_to_switch_state = true
	
	if event.is_action_pressed("ui_jump"):
		character.jump()
		next_state=air_state_var


func on_enter():
	# Adds the shield effect to the player and controls the animation for the player
	character.shield_up()
	character.animation_tree.set("parameters/state/transition_request","block")
	character.animation_tree.set("parameters/parry_transition/transition_request","block_start")
	
	# Sets the player to start parrying, used when the player is hit
	character.parrying=true
	
	# Resets the variables used which need to be reset
	want_to_switch_state=false
	can_switch_state=false
	can_move_state=false
	
	# Controls when the player stops parrying
	parry_timer.wait_time=parry_times[character.parry_time]
	parry_timer.start()
	# Controls the parry spamming, decreases the length each time
	character.parry_time+=1
	character.parry_time=clamp(character.parry_time,0,4)
	# When timer runs out reset the length of the parry
	character.get_node("timers/parry_spam_timer").start()


func on_exit():
	# Reset some variables
	character.blocking=false
	can_move_state=false


func _on_parry_timer_timeout():
	# Switchs the player from parrying to blocking
	character.parrying=false
	character.blocking=true
	# Lets the player move / leave block when they want
	can_switch_state=true
	can_move_state=true
	# Makes the player move slower while blocking
	character.speed=2.5


func _on_parry_spam_timer_timeout():
	# Resets length of parry
	character.parry_time=0


func succ_parry():
	# Adds delay for when there is a successful parry to let animation play (called from player)
	parry_timer.stop()
	parry_timer.wait_time=0.15
	parry_timer.start()
