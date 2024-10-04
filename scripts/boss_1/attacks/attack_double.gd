extends Boss_attack
# attack_double

@export var attack_spin_follow_double_var : Boss_attack

var collision_times=[0.5,0.7]
var attack_length=1.4
var follow_up_prob=2

func control_attack():
	animation_tree.set("parameters/attacks/transition_request","attack_double")
	control_collision(collision_times)
	finish_attack(attack_length,follow_up_prob,attack_spin_follow_double_var)





