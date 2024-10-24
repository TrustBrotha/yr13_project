extends Boss_attack
# attack_double

@export var attack_spin_follow_double_var : Boss_attack

var collision_times=[0.5,0.2,0.2,0.2]
var attack_length=1.4
var follow_up_prob=2
var damage=20.0


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
	var vel = (boss.transform.basis * Vector3(0, 0, 1)).normalized()*3*float(1.0/Global.boss_speed)
	var t=get_tree().create_tween()
	t.tween_property(boss,"velocity",vel,0.6*Global.boss_speed).set_trans(Tween.TRANS_LINEAR)
	t.tween_property(boss,"velocity",Vector3.ZERO,0.6*Global.boss_speed
	).set_trans(Tween.TRANS_LINEAR)


