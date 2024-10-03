extends State

# constants

# accessed states
@export var air_state_var : State
@export var dash_state_var : State
@export var block_state_var : State
@export var ground_state_var : State
@export var attack_state_var : State

var can_leave_attack=false
var attack_times=[0.65,0.65,0.65]
var combo=1
func state_process(delta):
	if not character.is_on_floor():
		next_state = air_state_var
	
	character.velocity.x = lerp(character.velocity.x,0.0,0.3)
	character.velocity.z = lerp(character.velocity.z,0.0,0.3)
	
	if can_leave_attack==true:
		if Input.is_action_pressed("block"):
			next_state=block_state_var
		elif (Input.is_action_pressed("ui_left") or
			Input.is_action_pressed("ui_right") or
			Input.is_action_pressed("ui_forward") or
			Input.is_action_pressed("ui_back")
			):
			next_state = ground_state_var
			combo+=1
			if combo>3:
				combo=1
		
			

func state_input(event : InputEvent):
	if can_leave_attack==true:
		if event.is_action_pressed("attack"):
			next_state=attack_state_var
			combo+=1
			if combo>3:
				combo=1
		
		elif event.is_action_pressed("ui_jump"):
			character.jump()
		
		elif event.is_action_pressed("ui_dash"):
			if character.can_dash:
				next_state = dash_state_var
		
		

func on_enter():
	print(combo)
	character.get_node("timers/combo_timer").stop()
	
	character.get_node("timers/exit_attack_timer").wait_time=attack_times[combo-1]
	character.get_node("timers/exit_attack_timer").start()
	
	character.animation_tree.set("parameters/combo/transition_request","combo%s"%combo)
	character.animation_tree.set("parameters/state/transition_request","attack")


func on_exit():
	can_leave_attack=false
	character.get_node("timers/exit_attack_timer").stop()
	character.get_node("timers/force_exit_attack_timer").stop()


func _on_exit_attack_timer_timeout():
	can_leave_attack=true
	
	character.get_node("timers/force_exit_attack_timer").wait_time=0.3
	character.get_node("timers/force_exit_attack_timer").start()
	character.get_node("timers/combo_timer").wait_time=0.4
	character.get_node("timers/combo_timer").start()


func _on_force_exit_attack_timer_timeout():
	combo=1
	next_state=ground_state_var


func _on_combo_timer_timeout():
	combo=1
