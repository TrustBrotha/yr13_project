extends Boss_attack
# attack_stab_1

@export var attack_stab_double_follow_stab_1 : Boss_attack

var collision_times = [0.4, 0.2]
var attack_length = 0.9
var follow_up_prob = 3
var damage = 30.0
var attack_move_speed = 12


# Starts everything the attacks needs
func control_attack():
	# Sets damage used by the player / sets animation
	Global.boss_current_attack_damage = damage
	animation_tree.set("parameters/attacks/transition_request", "attack_stab_1")
	# Calls the functions defined in the class
	control_collision(collision_times)
	finish_attack(attack_length, follow_up_prob, attack_stab_double_follow_stab_1)
	move()


# Makes the boss move towards the player
func move():
	await get_tree().create_timer(0.3 * Global.boss_speed).timeout
	# Calculates velocity with respect to rotation
	var vel = ((boss.transform.basis * Vector3(0, 0, 1)).normalized() * 
	attack_move_speed * float(1.0/Global.boss_speed))
	# Tweens the character's velocity
	var tween = get_tree().create_tween()
	tween.tween_property(boss, "velocity", vel, 0.3 * Global.boss_speed
	).set_trans(Tween.TRANS_LINEAR)
