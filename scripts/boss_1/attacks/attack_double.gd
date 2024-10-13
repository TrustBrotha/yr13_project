extends Boss_attack
# attack_double

@export var attack_spin_follow_double_var : Boss_attack

var collision_times=[0.5,0.2,0.2,0.2]
var attack_length=1.4
var follow_up_prob=2
var damage=20.0

func control_attack():
	Global.boss_current_attack_damage=damage
	animation_tree.set("parameters/attacks/transition_request","attack_double")
	control_collision(collision_times)
	finish_attack(attack_length,follow_up_prob,attack_spin_follow_double_var)
	move()


func move():
	var vel = (boss.transform.basis * Vector3(0, 0, 1)).normalized()*3
	var t=get_tree().create_tween()
	t.tween_property(boss,"velocity",vel,0.6).set_trans(Tween.TRANS_LINEAR)
	t.tween_property(boss,"velocity",Vector3.ZERO,0.6).set_trans(Tween.TRANS_LINEAR)


