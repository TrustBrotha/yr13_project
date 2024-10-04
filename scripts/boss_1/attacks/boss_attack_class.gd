extends Node
class_name Boss_attack


var boss : CharacterBody3D
var animation_tree : AnimationTree
var weapon_collision : CollisionShape3D



func control_collision(collision_times):
	weapon_collision.disabled=true
	for i in range(len(collision_times)):
		await get_tree().create_timer(collision_times[i]).timeout
		weapon_collision.disabled=not weapon_collision.disabled

func finish_attack(attack_length,follow_up_prob,follow_up_attack):
	await get_tree().create_timer(attack_length).timeout
	var r=randi_range(0,follow_up_prob)
	
	if r>0:
		if follow_up_attack!=null:
			get_parent().next_attack=follow_up_attack
	else:
		get_parent().attack_finished()
