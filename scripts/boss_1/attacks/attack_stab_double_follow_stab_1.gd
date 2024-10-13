extends Boss_attack
# attack_stab_double_follow_stab_1

var collision_times=[0.4,0.2,0.2,0.3]
var attack_length=1.2
var follow_up_prob=0
var damage=20.0

func control_attack():
	Global.boss_current_attack_damage=damage
	animation_tree.set("parameters/attacks/transition_request","attack_stab_double_follow_stab_1")
	control_collision(collision_times)
	finish_attack(attack_length,follow_up_prob,null)

