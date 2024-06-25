extends State

class_name dash_state


const DASH_SPEED = 15
const DASH_ACCEL = 0.5
@export var air_state_var : State
var dash_direction
var dashing = true

func state_process(delta):
	character.velocity.y = 0.0
	if dashing:
		character.velocity.x = lerp(character.velocity.x,dash_direction.x*DASH_SPEED,DASH_ACCEL)
		character.velocity.z = lerp(character.velocity.z,dash_direction.z*DASH_SPEED,DASH_ACCEL)
	
	if character.dash_timer.time_left == 0.05:
		dashing = false
		character.velocity.x = lerp(character.velocity.x,0.0,DASH_ACCEL)
		character.velocity.z = lerp(character.velocity.z,0.0,DASH_ACCEL)



func on_enter():
	character.dash_timer.start()
	dash_direction = character.direction

func state_input(event : InputEvent):
	pass



func on_exit():
	pass


func _on_dash_time_timeout():
	next_state = air_state_var
