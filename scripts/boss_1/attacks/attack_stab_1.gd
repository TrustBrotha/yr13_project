extends Boss_attack
# attack_stab_1

@export var attack_stab_double_follow_stab_1 : Boss_attack

var collision_times=[0.4,0.3]
var attack_length=0.8
var follow_up_prob=3

func control_attack():
	animation_tree.set("parameters/attacks/transition_request","attack_stab_1")
	control_collision(collision_times)
	finish_attack(attack_length,follow_up_prob,attack_stab_double_follow_stab_1)
	move()

func move():
	await get_tree().create_timer(0.3).timeout
	var vel = (boss.transform.basis * Vector3(0, 0, 1)).normalized()*8
	var t=get_tree().create_tween()
	t.tween_property(boss,"velocity",vel,0.3).set_trans(Tween.TRANS_LINEAR)
