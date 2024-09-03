extends State

@export var ground_state_var : State
@export var air_state_var : State
const JUMP_VELOCITY = 10
var want_to_switch_state=false
var can_switch_state=false

func state_process(delta):
	character.velocity.y -= gravity * delta
	if character.is_on_floor():
		character.velocity.x = lerp(character.velocity.x,0.0,character.ACCELERATION)
		character.velocity.z = lerp(character.velocity.z,0.0,character.ACCELERATION)
	
	if want_to_switch_state and can_switch_state:
		next_state=air_state_var

func state_input(event : InputEvent):
	if event.is_action_released("block"):
		want_to_switch_state = true
	
	if event.is_action_pressed("ui_jump"):
		character.velocity.y = JUMP_VELOCITY
		next_state=air_state_var

func on_enter():
	want_to_switch_state=false
	can_switch_state=false
	can_move_state=false
	character.get_node("timers/parry_timer").wait_time=0.2
	character.get_node("timers/parry_timer").start()
	character.animation_tree.set("parameters/state/transition_request","block")

func on_exit():
	can_move_state=false


func _on_parry_timer_timeout():
	can_switch_state=true
	can_move_state=true
	character.speed=2.5
