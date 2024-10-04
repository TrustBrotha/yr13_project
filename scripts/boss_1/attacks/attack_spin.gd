extends Boss_attack
# attack_spin

var collision_times=[0.5,0.4]
var attack_length=1.0
var follow_up_prob=0


func control_attack():
	animation_tree.set("parameters/attacks/transition_request","attack_spin")
	control_collision(collision_times)
	finish_attack(attack_length,follow_up_prob,null)
