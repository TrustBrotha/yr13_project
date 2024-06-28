extends State

@export var ground_state_var : State
@export var air_state_var : State

var want_to_switch_state = false
var can_switch_states = false
func state_process(delta):
	character.velocity.y -= gravity * delta
	if character.is_on_floor():
		character.velocity.x = lerp(character.velocity.x,0.0,character.ACCELERATION)
		character.velocity.z = lerp(character.velocity.z,0.0,character.ACCELERATION)
	
	if want_to_switch_state == true and can_switch_states == true:
		character.block_up = false
		if character.is_on_floor():
			next_state = ground_state_var
		else:
			next_state = air_state_var

func state_input(event : InputEvent):
	if event.is_action_released("block"):
		want_to_switch_state = true
		

func on_enter():
	character.animation_player.play("parry_start")

func on_exit():
	want_to_switch_state = false
	can_switch_states = false
	character.animation_player.play("parry_end")




func _on_player_parry_done():
	can_switch_states = true
