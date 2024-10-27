extends Boss_attack
# attack_double

@export var attack_spin_follow_double_var : Boss_attack

var collision_times=[0.5,0.2,0.25,0.2] # The unedited time between switching the collision
var attack_length=1.4 # The unedited length of time of the attack
var follow_up_prob=2 # Probability of executing follow up attack (0=no follow up)
var damage=20.0 # Damage of this attack
var attack_move_speed=6 # Max speed of boss during attack


# Starts everything the attacks needs
func control_attack():
	# Sets damage used by the player / sets animation
	Global.boss_current_attack_damage=damage
	animation_tree.set("parameters/attacks/transition_request","attack_double")
	# Calls the functions defined in the class
	control_collision(collision_times)
	finish_attack(attack_length,follow_up_prob,attack_spin_follow_double_var)
	move()


# Makes the boss move towards the player
func move():
	# Calculates velocity with respect to rotation
	var vel = ((boss.transform.basis * Vector3(0, 0, 1)).normalized() * 
	attack_move_speed * float(1.0/Global.boss_speed))
	# Tweens the character's velocity
	var tween=get_tree().create_tween()
	tween.tween_property(boss,"velocity",vel,0.6 * Global.boss_speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(boss,"velocity",Vector3.ZERO,0.6 * Global.boss_speed
	).set_trans(Tween.TRANS_LINEAR)


