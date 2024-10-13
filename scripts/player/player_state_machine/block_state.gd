extends State

@export var ground_state_var : State
@export var air_state_var : State
var want_to_switch_state=false
var can_switch_state=false

var parry_times=[0.2,0.15,0.1,0.05,0.01]


func state_process(delta):
	character.velocity.y -= gravity * delta
	if character.is_on_floor():
		character.velocity.x = lerp(character.velocity.x,0.0,character.ACCELERATION)
		character.velocity.z = lerp(character.velocity.z,0.0,character.ACCELERATION)
	
	if want_to_switch_state and can_switch_state:
		if character.is_on_floor():
			next_state=ground_state_var
		else:
			next_state=air_state_var

func state_input(event : InputEvent):
	if event.is_action_released("block"):
		want_to_switch_state = true
	
	if event.is_action_pressed("ui_jump"):
		character.jump()
		next_state=air_state_var

func on_enter():
	character.animation_tree.set("parameters/parry_transition/blend_amount",0.0)
	character.parrying=true
	want_to_switch_state=false
	can_switch_state=false
	can_move_state=false
	character.get_node("timers/parry_timer").wait_time=parry_times[character.parry_time]
	character.get_node("timers/parry_timer").start()
	character.parry_time+=1
	character.parry_time=clamp(character.parry_time,0,4)
	character.get_node("timers/parry_spam_timer").start()
	character.animation_tree.set("parameters/state/transition_request","block")

func on_exit():
	character.blocking=false
	can_move_state=false


func _on_parry_timer_timeout():
	character.parrying=false
	character.blocking=true
	can_switch_state=true
	can_move_state=true
	character.speed=2.5


func _on_parry_spam_timer_timeout():
	character.parry_time=0
