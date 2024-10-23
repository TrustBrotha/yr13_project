extends State
@export var attack_state_var : State
@export var idle_state_var : State
@export var dodge_back_state_var : State

var decision=randi_range(0,2)


func state_process(delta):
	character.velocity.x=lerp(character.velocity.x,0.0,0.3)
	character.velocity.z=lerp(character.velocity.z,0.0,0.3)
	
	if character.player.state_machine.current_state.name!="attack":
		if character.player_relative_location.length() < character.attack_range:
			next_state=attack_state_var
		else:
			next_state=idle_state_var
	else:
		if character.player.state_machine.current_state.combo==2:
			
			if decision==0:
				next_state=dodge_back_state_var
			else:
				pass
		elif character.player.state_machine.current_state.combo==3:
			if decision==0:
				next_state=dodge_back_state_var
			else:
				next_state=attack_state_var
		
	
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta


func state_input(event : InputEvent):
	pass


func on_enter():
	decision=randi_range(0,2)
	character.blocking=true
	character.animation_tree.set("parameters/state/transition_request","block")


func on_exit():
	character.blocking=false
