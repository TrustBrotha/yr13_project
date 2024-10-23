extends Node
class_name Boss_attack


var boss : CharacterBody3D
var animation_tree : AnimationTree
var weapon_collision : CollisionShape3D



func control_collision(collision_times):
	var adjusted_times=[]
	for i in len(collision_times):
		adjusted_times.append(collision_times[i]*Global.boss_speed)
	
	boss.attacking=true
	weapon_collision.disabled=true
	for i in range(len(adjusted_times)):
		await get_tree().create_timer(adjusted_times[i]).timeout
		weapon_collision.disabled=not weapon_collision.disabled


func finish_attack(attack_length,follow_up_prob,follow_up_attack):
	var adjusted_length
	adjusted_length=attack_length*Global.boss_speed
	await get_tree().create_timer(adjusted_length).timeout
	boss.attacking=false
	var r=randi_range(0,follow_up_prob)
	
	if r>0:
		if follow_up_attack!=null:
			
			if boss.player_relative_location.length() > boss.attack_range:
				get_parent().next_state=get_parent().idle_state_var
			
			else:
				get_parent().current_attack=follow_up_attack
				get_parent().attack()
	else:
		get_parent().attack_finished()
