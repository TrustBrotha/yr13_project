extends Boss_attack
# attack_spin

var collision_times=[0.5,0.4]
var attack_length=1.0
var follow_up_prob=0
var damage=40.0

func control_attack():
	Global.boss_current_attack_damage=damage
	animation_tree.set("parameters/attacks/transition_request","attack_spin")
	control_collision(collision_times)
	finish_attack(attack_length,follow_up_prob,null)
	move()

func move():
	await get_tree().create_timer(0.3).timeout
	var vel = (boss.transform.basis * Vector3(0, 0, 1)).normalized()*7
	var t=get_tree().create_tween()
	t.tween_property(boss,"velocity",vel,0.3).set_trans(Tween.TRANS_LINEAR)
