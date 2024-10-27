extends Node
class_name Boss_attack

# vars which are set from attack state to be used here
var boss : CharacterBody3D
var animation_tree : AnimationTree
var weapon_collision : CollisionShape3D


# Controls when the bosses weapon has collision during the attack
func control_collision(collision_times):
	# Adjusts the default times to fit the bosses current speed / collision delay
	var adjusted_times = []
	for i in len(collision_times):
		adjusted_times.append(collision_times[i] * Global.boss_speed)
	adjusted_times[0] += Global.boss_attack_delay
	
	# Sets boss to be attacking (used to stop knockback while attacking)
	boss.attacking = true
	
	# Initially sets cillision to be off
	weapon_collision.disabled = true
	
	# After each amount of time has passed in the collision times array flip the bool controlling
	# The collision
	for i in range(len(adjusted_times)):
		await get_tree().create_timer(adjusted_times[i]).timeout
		weapon_collision.disabled = not weapon_collision.disabled
		
		# Plays swing noise
		if not weapon_collision.disabled:
			boss.play_attack_noise()


# Controls what happens when the boss finishes an attack
func finish_attack(attack_length, follow_up_prob, follow_up_attack):
	# Adjusts the default times to fit the bosses current speed / collision delay
	var adjusted_length
	adjusted_length = attack_length * Global.boss_speed + Global.boss_attack_delay
	
	# Waits until the boss finishes the attack
	await get_tree().create_timer(adjusted_length).timeout
	
	# Sets boss to stop attacking (boss can now recieve knockback)
	boss.attacking = false
	
	# Makes a random number to decide wether to do a follow up attack
	# Attacks with no follow up have a probability of 0
	var random_num = randi_range(0, follow_up_prob)
	if random_num > 0 and follow_up_attack != null:
		# If the player moved out of attack range during first attack, dont follow up
		if boss.player_relative_location.length() > boss.attack_range:
			get_parent().next_state = get_parent().idle_state_var
		
		# If player remained in range, follow up
		else:
			get_parent().current_attack = follow_up_attack
			get_parent().attack()
	
	# If not following up, call attack finished script
	else:
		get_parent().attack_finished()
