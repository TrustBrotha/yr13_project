extends State
@export var attack_state_var : State

var patrol_dist=6.0
var patrol_target : Vector3
var patrol_dir=1
var attack=0

func state_process(delta):
	#print([patrol_dist,patrol_dir,attack])
	if character.player_relative_location.length() < character.attack_range:
		next_state=attack_state_var
	
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta
	
	if attack==0:
		
		character.animation_tree.set("parameters/walk_type/transition_request","walk_else")
		var velocity_difference := (Quaternion.from_euler(character.global_rotation).inverse() * character.velocity);
		var blend_position := Vector2(-velocity_difference.x * 1.0, velocity_difference.z * 1.0, 
		).normalized()
		character.animation_tree.set(
					"parameters/walk_blend/blend_position",
					lerp(character.animation_tree.get("parameters/walk_blend/blend_position"),
					blend_position,0.1))
		
		
		if (character.player.global_position-character.global_position).length() > patrol_dist:
			var d=character.player_relative_location.length()-patrol_dist
			patrol_target=character.global_position + character.player_relative_location.normalized()*d
			
			character.velocity.x=((patrol_target-character.global_position).normalized()*character.SPEED).x*0.4
			character.velocity.z=((patrol_target-character.global_position).normalized()*character.SPEED).z*0.4
		else:
			var direction
			if patrol_dir == 1:
				direction = (character.transform.basis * Vector3(1, 0, 0)).normalized()
			else:
				direction = (character.transform.basis * Vector3(-1, 0, 0)).normalized()
			character.velocity.x = direction.x*character.SPEED*0.4
			character.velocity.z = direction.z*character.SPEED*0.4
	
	
	else:
		character.animation_tree.set("parameters/walk_type/transition_request","walk_towards")
		var direction=(character.player.global_position-character.global_position).normalized()
		character.velocity.x = direction.x*character.SPEED*1.5
		character.velocity.z = direction.z*character.SPEED*1.5
	

func state_input(event : InputEvent):
	pass

func on_enter():
	character.animation_tree.set("parameters/state/transition_request","idle")
	character.get_node("timers/find_idle_pos").start()

func on_exit():
	character.get_node("timers/find_idle_pos").stop()


func _on_find_idle_pos_timeout():
	patrol_dist=float(randi_range(6,18))/2
	patrol_dir*=-1
	character.get_node("timers/find_idle_pos").start()
	if attack==1:
		attack=0
	else:
		attack=randi_range(0,1)
	
	
	
