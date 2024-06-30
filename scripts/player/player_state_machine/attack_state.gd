extends State

@export var ground_state_var : State
@export var air_state_var : State

var last_dir

func state_process(delta):
	if character.is_on_floor():
		character.velocity.x = lerp(character.velocity.x,0.0,character.ACCELERATION)
		character.velocity.z = lerp(character.velocity.z,0.0,character.ACCELERATION)
	
	if character.camera_locked == false:
		character.sprite.rotation.y=lerp_angle(character.sprite.rotation.y,atan2(last_dir.x,last_dir.z)+PI,8*delta)
	elif character.camera_locked == true:
		character.sprite.rotation.y = character.cam_pivot_y.rotation.y

func state_input(event : InputEvent):
	pass

func on_enter():
	
	last_dir = character.velocity
	character.animation_player.play("attack_start")

func on_exit():
	character.animation_player.play("attack_end")

func end_attack():
	if character.is_on_floor():
		next_state = ground_state_var
	else:
		next_state = air_state_var
