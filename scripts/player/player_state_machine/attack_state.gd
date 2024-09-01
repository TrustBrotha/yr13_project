extends State

@export var ground_state_var : State
@export var air_state_var : State


func state_process(delta):
	character.velocity.x = lerp(character.velocity.x,0.0,0.3)
	character.velocity.z = lerp(character.velocity.z,0.0,0.3)

func state_input(event : InputEvent):
	pass

func on_enter():
	var timer= character.get_node("timers/exit_attack_timer")
	timer.wait_time=0.65
	timer.start()
	character.animation_tree.set("parameters/state/transition_request","attack")

func on_exit():
	pass


func _on_exit_attack_timer_timeout():
	next_state=ground_state_var
