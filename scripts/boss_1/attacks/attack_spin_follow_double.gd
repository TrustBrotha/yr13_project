extends Boss_attack
# attack_spin_follow_double

var collision_times=[0.5,0.5]
var attack_length=1.1
var follow_up_prob=0


func control_attack():
	animation_tree.set("parameters/attacks/transition_request","attack_spin_follow_double")
	control_collision(collision_times)
	finish_attack(attack_length,follow_up_prob,null)

