extends State
@export var attack_state_var : State
@export var idle_state_var : State



func state_process(delta):
	character.velocity.x=lerp(character.velocity.x,0.0,0.3)
	character.velocity.z=lerp(character.velocity.z,0.0,0.3)
	
	if character.player.state_machine.current_state.name!="attack":
		character.blocking=false
		if character.player_relative_location.length() < character.attack_range:
			next_state=attack_state_var
		else:
			next_state=idle_state_var
	
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta


func state_input(event : InputEvent):
	pass

func on_enter():
	character.blocking=true
	
	character.animation_tree.set("parameters/state/transition_request","block")

func on_exit():
	pass
