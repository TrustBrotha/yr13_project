extends State

# Accessed states
@export var air_state_var : State
@export var dash_state_var : State
@export var block_state_var : State
@export var ground_state_var : State
@export var attack_state_var : State

# Data used to control attack collision
@export var weapon_collision1 : CollisionShape3D
@export var weapon_collision2 : CollisionShape3D
@export var weapon_collision3 : CollisionShape3D
@export var weapon_collision4 : CollisionShape3D
var left_weapon_collision = []
var right_weapon_collision = []

# Data used to control when the weapon collision is on or off
var all_left_collision_times = [[0.2, 0.2], [0.3, 0.2], [0.2, 0.3]]
var all_right_collision_times = [[0.3, 0.2], [0.4, 0.2], [0.2, 0.3]]

# Controls the movement of the player when attacking
var attack_move_speeds = [0.4, 0.5, 0.5]
var attack_vels = [8, 8, 15]
var attack_times = [0.65, 0.65, 0.65]

# Controls when the player can stop the attack animation
var can_leave_attack = false
var can_combo = false
var combo_time = 0.15
# Controls which attack is used
var combo = 1

# Assigns the sounds used so a variable to be accessed through code
var swing_sounds = [
	load("res://sfx/player/player_swing_1.wav"), 
	load("res://sfx/player/player_swing_2.wav"), 
	load("res://sfx/player/player_swing_3.wav"), 
]


# Sets the collision data up to be used in code
func _ready():
	left_weapon_collision = [weapon_collision1, weapon_collision2]
	right_weapon_collision = [weapon_collision3, weapon_collision4]


func state_process(delta):
	# Makes the player slow down when attacking
	character.velocity.x = lerp(character.velocity.x, 0.0, 0.3)
	character.velocity.z = lerp(character.velocity.z, 0.0, 0.3)
	
	# Controls when the player can leave the attack state and the states which can be changed into
	if can_leave_attack:
		if Input.is_action_pressed("block"):
			next_state = block_state_var
			combo = 1
		elif (Input.is_action_pressed("left") or
			Input.is_action_pressed("right") or
			Input.is_action_pressed("ui_forward") or
			Input.is_action_pressed("ui_back")
		):
			combo = 1
			next_state = ground_state_var
	
	# Saves combo to be used in other places such as from the boss script
	Global.player_combo = combo


func state_input(event : InputEvent):
	# continues the combo
	if can_combo:
		if event.is_action_pressed("attack"):
			next_state = attack_state_var
			# Progresses combo
			combo += 1
			if combo > 3:
				combo = 1
			
	# Controls which states the player moves into when stopping attack when it can change
	if can_leave_attack:
		if event.is_action_pressed("ui_jump"):
			combo = 1
			character.jump()
		
		elif event.is_action_pressed("ui_dash"):
			if character.can_dash:
				combo = 1
				next_state = dash_state_var


func on_enter():
	# Controls the timing for the attacks
	character.get_node("timers/combo_timer").stop()
	character.get_node("timers/exit_attack_timer").wait_time = attack_times[combo - 1] + 0.05
	character.get_node("timers/exit_attack_timer").start()
	
	# Sets animation 
	character.animation_tree.set("parameters/combo/transition_request", "combo%s"%combo)
	character.animation_tree.set("parameters/state/transition_request", "attack")
	
	control_collision()
	move()


func control_collision():
	collisions(left_weapon_collision, all_left_collision_times)
	collisions(right_weapon_collision, all_right_collision_times)


# Controls when the players weapons have collision or not
# Inputs: which side needs to be changed, the time data for that side
func collisions(side_collisions, side_collision_times):
	var state = true # Flipping the bool directly didn't work so state used instead
	# Disables collision to start
	change_collision(side_collisions, state)
	# Gets the time data for the current combo
	var collision_times = side_collision_times[combo - 1]
	for i in range(len(collision_times)):
		# Each time the about of time passes flips whether the collision is on or not
		await get_tree().create_timer(collision_times[i]).timeout
		state = not state
		if not state:
			character.play_attack_sound()
		# Sets collision
		change_collision(side_collisions, state)


func change_collision(collisions, state):
	# Goes through all of the collisions in the collisions input
	# and sets the disabled to the input: state
	for weapon in collisions:
		weapon.disabled = state


func move():
	# Controls the movement of the player when they are attacking
	var vel = (character.sprite.transform.basis * Vector3(0, 0, 1)
	).normalized() * attack_vels[combo - 1]
	var tween = get_tree().create_tween()
	tween.tween_property(character, "velocity", vel, attack_move_speeds[combo - 1]
	).set_trans(Tween.TRANS_LINEAR)


func on_exit():
	# Resets variables and timers when exitting the state
	can_leave_attack = false
	can_combo = false
	character.get_node("timers/exit_attack_timer").stop()
	character.get_node("timers/force_exit_attack_timer").stop()


func _on_exit_attack_timer_timeout():
	# Lets the player continue to combo after the attack
	# (Adds delay beween being able to combo and leaving the attack state
	can_combo = true
	character.get_node("timers/combo_timer").wait_time = combo_time
	character.get_node("timers/combo_timer").start()
	# Sets timer which forces the player leave attack state after a set amount of time
	# after the attack is finished
	character.get_node("timers/force_exit_attack_timer").wait_time = combo_time + 0.15
	character.get_node("timers/force_exit_attack_timer").start()


func _on_force_exit_attack_timer_timeout():
	# Resets combo and moves player out of attack state
	combo = 1
	next_state = ground_state_var


func _on_combo_timer_timeout():
	# lets player leave attack state
	can_leave_attack = true



