extends CharacterBody3D

const SPEED = 5

# Sets some nodes / scenes to vars so that they can be accessed easily through code
@export var animation_tree : AnimationTree
@export var state_machine : Node
@export var weapon_coll : CollisionShape3D
@onready var player = get_parent().get_node("player")

# States which are accessed through this script file
@export var blank_state_var : State
@export var attack_state_var : State
@export var idle_state_var : State

# Instanced scenes 
@export var parry_particle_var : PackedScene
@export var cloak_bone_scene : PackedScene
@export var sound_effect_scene : PackedScene

# Array of bone names for Jigglebones to be attached to
@onready var cloak_bones = [
	"cloak_outer_2.L", "cloak_outer_3.L", "cloak_outer_5.L", "cloak_outer_7.L", 
	"cloak_inner_2.L", "cloak_inner_3.L", "cloak_inner_5.L", "cloak_inner_7.L", 
	"cloak_outer_2.R", "cloak_outer_3.R", "cloak_outer_5.R", "cloak_outer_7.R", 
	"cloak_inner_2.R", "cloak_inner_3.R", "cloak_inner_5.R", "cloak_inner_7.R", 
	"cloak_front_2", "cloak_front_3", "cloak_back_2", 
	]

# Preloads sound files
var swing_sounds = [
	load("res://sfx/boss_1/boss_swing_1.wav"), 
	load("res://sfx/boss_1/boss_swing_2.wav"), 
]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


var attack_range = 3.5 # When the dist between player and boss is less than this, boss attacks
var player_relative_location # The vector from the boss to the player

var attacking = false # Set from the boss_attack_class script, used as conditional when hit to
# Decide whether or not the get knockbacked (having 2 tweens affect same property is bad)

var immune = false # Used to make sure the same player hitbox doesn't damage the boss twice
var blocking = false # When the boss is blocking, takes half damage

var wants_to_chase = false # Used by idle state and set in attack state to make the boss chase the
# Player if they run away after an attack
var half_health_attack_done = false # Makes the special attack when at half health only happen once

func _ready():
	# Checks whether cloth has been enabled in settings
	if Global.cloth:
		create_cloak_bones()


func create_cloak_bones():
	# Adds a Jigglebone to each cloth bone
	for i in range(len(cloak_bones)):
		var cloak_bone = cloak_bone_scene.instantiate()
		cloak_bone.bone_name = cloak_bones[i]
		cloak_bone.stiffness = 0.3
		cloak_bone.forward_axis = 4
		$boss_1_model/Armature/GeneralSkeleton.add_child(cloak_bone)


func _physics_process(delta):
	# Useful print statement
	#print(state_machine.current_state.name)
	
	# Calls to animate the cloth each frame
	animate_cloak_roots()
	
	# Updates the vector from the boss to the player
	player_relative_location = player.global_position - global_position
	
	# Makes boss look at player
	var direction = global_position - player.global_position
	rotation.y = atan2(direction.x, direction.z) + PI
	
	# Kinda scuffed but controls the rebound of the boss when hit while blocking
	animation_tree.set(
		"parameters/block_blend/blend_amount", 
		lerp(animation_tree.get("parameters/block_blend/blend_amount"), 
		0.0, 0.1))
	
	# Calls special attack when at half health
	if not half_health_attack_done:
		if Global.boss_health < float(Global.boss_max_health) / 2:
			half_health_attack_done = true
			laser_attack(6, 2)
	
	# Updates movement
	move_and_slide()


# Moves cloth based on boss speed
func animate_cloak_roots():
	var cloak_rot = (0.01 * PI * velocity.length())
	var quat_rot = Quaternion(Vector3(1, 0, 0), cloak_rot)
	var bone_idxs = [42, 49, 56, 63]
	for i in range(4):
		$boss_1_model/Armature/GeneralSkeleton.set_bone_pose_rotation(bone_idxs[i], quat_rot)


# Controls the special laser attack, called from idle and this script
func laser_attack(gap_time, beam_type):
	# Sets state to be empty, so other states dont interfere
	state_machine.current_state.next_state = blank_state_var
	
	# Controls the starting animation
	animation_tree.set("parameters/state/transition_request", "attack")
	animation_tree.set("parameters/attacks/transition_request", "attack_fly_up")
	
	# Makes the boss fly into the air (after delay so that the jumping animation feels right
	await get_tree().create_timer(0.25 * Global.boss_speed).timeout 
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position + Vector3(0, 6, 0), 
	0.45 * Global.boss_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# Calls main scene to spawn lasers.
	get_parent().spawn_beams(beam_type)
	
	# Adds delay for boss to wait in the air while the lasers fire
	await get_tree().create_timer(gap_time).timeout
	
	# Starts the slam animation
	animation_tree.set("parameters/attacks/transition_request", "attack_fly_slam")
	
	# Enable collision
	weapon_coll.disabled = false
	
	# Delay for animation to sync with movement
	await get_tree().create_timer(0.4 * Global.boss_speed).timeout 
	
	# Calculates position between boss and player but 2.5 meters away from the player
	var target = player.global_position + (global_position - player.global_position
	).normalized() * 2.5
	target.y = player.global_position.y
	
	# Moves boss towards the target
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self, "global_position", target, 0.45 * Global.boss_speed
	).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	# Turns off collision
	await get_tree().create_timer(0.5 * Global.boss_speed).timeout
	weapon_coll.disabled = true
	
	# Starts normal attack
	await get_tree().create_timer(0.2 * Global.boss_speed).timeout
	state_machine.current_state.next_state = idle_state_var


# Controls different cases when boss hit
func _on_area_3d_area_entered(area):
	# Only does anything if can be hit
	if not immune:
		immune = true
		$timers/immunity_timer.start()
		
		# Adds some camera shake
		player.camera.add_trauma(0.1)
		
		# Controls knockback if attack tween isn't running
		if not attacking:
			var vel = (transform.basis * Vector3(0, 0, -1)).normalized() * 3
			var t = get_tree().create_tween()
			t.tween_property(self, "velocity", 
					vel, 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
		# If blocking take half damage and play block hit animation
		if blocking:
			animation_tree.set("parameters/block_blend/blend_amount", 1.0)
			Global.boss_health -= Global.player_attack_damage * 0.5
		
		# If not blocking take full damage and create damage particles
		elif not blocking:
			var particles = parry_particle_var.instantiate()
			particles.emitting = true
			particles.process_material.color = Color.RED
			$particles.add_child(particles)
			Global.boss_health -= Global.player_attack_damage * 1.0
	
	
	# Checks if dead, if so stops most processes (blank state empty)
	if Global.boss_health <= 0:
		get_parent().death_effect(global_position)
		global_position.y=-5.0
		state_machine.current_state.next_state = blank_state_var


# resets immunity
func _on_immunity_timer_timeout():
	immune = false


# Controls swing noises
func play_attack_noise():
	var sfx = sound_effect_scene.instantiate()
	sfx.play_sound(swing_sounds.pick_random(), 0)
	$sounds.add_child(sfx)
