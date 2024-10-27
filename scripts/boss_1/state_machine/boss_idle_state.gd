extends State

# States which can be moved into
@export var attack_state_var : State
@export var block_state_var : State

var patrol_dist=6.0 # Range at which the boss circles player
var patrol_target : Vector3 # Position which boss aims at, based on patrol dist
var patrol_dir=1 # Controls if boss moves left or right around player
var attack=0 # 0 means not charging, >0 means charging
var block_prepared=false # Controls when the boss can block
var speed_adjustment = 0.4 # speed_multiplier so make the boss faster or slower in different cases

func state_process(delta):
	# If player close, attack
	if character.player_relative_location.length() < character.attack_range:
		next_state=attack_state_var
	
	# If getting attacked, block
	if block_prepared==true:
		if (
			character.player_relative_location.length() < character.attack_range and
			character.player.state_machine.current_state.name=="attack"
		):
			next_state=block_state_var
	
	# If boss is not charging
	if attack==0:
		speed_adjustment=0.4
		# Control animation mode (walk else, means not walking towards)
		character.animation_tree.set("parameters/walk_type/transition_request","walk_else")
		
		# Calculates the direction the boss should be walking based on its rotation
		var velocity_difference := (Quaternion.from_euler(character.global_rotation
		).inverse() * character.velocity);
		var blend_position := Vector2(-velocity_difference.x * 1.0, velocity_difference.z * 1.0,
		).normalized()
		
		# Set the calculated position into the blend2d parameter in the animation tree
		character.animation_tree.set(
					"parameters/walk_blend/blend_position",
					lerp(character.animation_tree.get("parameters/walk_blend/blend_position"),
					blend_position,0.1))
		
		# If the boss if further away from the player than its patrol dist
		if (character.player.global_position-character.global_position).length() > patrol_dist:
			# Calculates the dist from the boss the patrol distance is
			var dist=character.player_relative_location.length()-patrol_dist
			
			# Calculate the position the boss wants to move to 
			patrol_target=(character.global_position + 
			character.player_relative_location.normalized()*dist)
			
			# Boss moves towards patrol target
			character.velocity.x=((patrol_target-character.global_position
			).normalized()*character.SPEED).x*speed_adjustment
			character.velocity.z=((patrol_target-character.global_position
			).normalized()*character.SPEED).z*speed_adjustment
		
		# If the boss is closer than the patrol distance, circle player
		else:
			# Based on the direction the boss is moving around the player (1=left,-1=right)
			# Calculate the direction with respoct to the bosses rotation
			var direction = (character.transform.basis * Vector3(patrol_dir, 0, 0)).normalized()
			
			# Apply the calculated direction to the bosses velocity
			character.velocity.x = direction.x*character.SPEED*speed_adjustment
			character.velocity.z = direction.z*character.SPEED*speed_adjustment
	
	# If charging, walk quickly towards player
	else:
		# Makes boss walk faster and changes animation to walking
		speed_adjustment=1.5
		character.animation_tree.set("parameters/walk_type/transition_request","walk_towards")
		
		# Calculates the direction towards player and applies it to the velocity
		var direction=(character.player.global_position-character.global_position).normalized()
		character.velocity.x = direction.x*character.SPEED*speed_adjustment
		character.velocity.z = direction.z*character.SPEED*speed_adjustment
	
	# Applies gravity
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta


func on_enter():
	# If coming from attack state, chase player
	if character.wants_to_chase==true:
		attack=1
	character.wants_to_chase=false
	# Reset block preparedness
	block_prepared=true
	
	# Changes animation state
	character.animation_tree.set("parameters/state/transition_request","idle")
	
	# Starts timer to make new decision
	character.get_node("timers/find_idle_pos").start()


func on_exit():
	# Reset block preparedness
	block_prepared=false
	
	# Stops decision making
	character.get_node("timers/find_idle_pos").stop()


func _on_find_idle_pos_timeout():
	# Decide to do laser attack or not
	var laser=[0,0,1].pick_random()
	if laser==1:
		character.laser_attack(2,1)
	
	# Create new patrol distance / flip patrol direction
	patrol_dist=float(randi_range(6,18))/2
	patrol_dir*=-1
	# Restart timer
	character.get_node("timers/find_idle_pos").start()
	
	# If chasing, stop
	if attack==1:
		attack=0
	# If not chasing, decide whether or not to start chasing
	else:
		attack=[0,0,1].pick_random()

