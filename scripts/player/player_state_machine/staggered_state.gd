extends State

var count = 0
@export var ground_state_var : State
@export var air_state_var : State

func state_process(delta):
	character.velocity.y -= gravity * delta
	count+=1
	if count >= 50:
		if character.is_on_floor():
			next_state = ground_state_var
		else:
			next_state = air_state_var
	
	character.velocity.x = lerp(character.velocity.x,0.0,0.1)
	character.velocity.z = lerp(character.velocity.z,0.0,0.1)

func state_input(event : InputEvent):
	pass

func on_enter():
	count = 0
	character.sprite.get_node("player_asset").material.albedo_color = Color.RED
	character.animation_player.play("RESET")

func on_exit():
	character.sprite.get_node("player_asset").material.albedo_color = Color.WHITE
