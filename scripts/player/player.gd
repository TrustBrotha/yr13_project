extends CharacterBody3D

# Constants
const ACCELERATION = 0.2
const SPRITE_TURN_SPEED = 12
const JUMP_VELOCITY = 8
const SENSITIVITY=0.1

# Preloaded nodes to be accessed easier (sometimes not done because too lazy)
@onready var cam_pivot_x = $cam_origin_y/cam_origin_x
@onready var cam_pivot_y = $cam_origin_y
@onready var camera = $cam_origin_y/cam_origin_x/camera_spring/Camera3D
@onready var sprite = $player_model
@onready var timers = $timers
@onready var animation_player = $player_model/Sekiro_like_player_character/AnimationPlayer
@onready var animation_tree = $player_model/Sekiro_like_player_character/AnimationTree

# Used to get information about the boss, such as its position
@onready var boss=get_parent().get_node("boss_1")

# Defines the state machine to me manipulated as a variable
@onready var state_machine : CharacterStateMachine = $character_state_machine
# Defines some states so that the state machine can be forced into these states from this file
@export var parry_particle_var : PackedScene
@export var staggered_state_var : State
@export var dead_state_var : State

# Loads the spinning shield effect scene used to show when the player is parrying
@export var shield_scene : PackedScene

# Loads the scene which plays the 3d sfx / preloads some of the sound effects used
@export var sound_effect_scene : PackedScene
var parry_sounds=[
	load("res://sfx/player/deflect_1.wav"),
	load("res://sfx/player/deflect_2.wav"),
	load("res://sfx/player/deflect_3.wav"),
	load("res://sfx/player/deflect_4.wav"),
	]
var swing_sounds=[
	load("res://sfx/player/player_swing_1.wav"),
	load("res://sfx/player/player_swing_2.wav"),
	load("res://sfx/player/player_swing_3.wav"),
	]

# Makes a list of the bones which need a jigglebone attached
@onready var cloak_bones = [
	"cloak_2_O.R","cloak_3_O.R","cloak_4_O.R","cloak_5_O.R","cloak_6_O.R","cloak_7_O.R",
	"cloak_2_O.L","cloak_3_O.L","cloak_4_O.L","cloak_5_O.L","cloak_6_O.L","cloak_7_O.L",
	"cloak_2_I.R","cloak_3_I.R","cloak_4_I.R","cloak_5_I.R","cloak_6_I.R","cloak_7_I.R",
	"cloak_2_I.L","cloak_3_I.L","cloak_4_I.L","cloak_5_I.L","cloak_6_I.L","cloak_7_I.L",
	"cloak_mid_2","cloak_mid_3","cloak_mid_4","cloak_mid_5","cloak_mid_6","cloak_mid_7",
	]
# Loads the jigglebone scene with some preset settings
@export var cloak_bone_scene : PackedScene


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Movement variables
var direction=Vector3.ZERO # Used for movement
var last_direction=Vector3.ZERO # Covers edge case when character is not moving
var can_dash = true # Used by state machine as conditional to enter dash state
var wants_to_jump = false # Stored buffer when pressing space just before hitting ground
var speed = 10.0 # Controls the speed of the player
var moving=false # Used to control animations in some states
var target_rotation=0.0 # Used to make rotation of the sprite smoother
var input_dir # Converts keyboard controls to usable data
var running=false # Used to control animations / cloth physics
var jump_spam_fix=false # Stops spamming jump reseting jump animation
# Camera variables
var cam_mode="free" # Controls whether or not the player is locked on
var cam_targets=[] # Array of enemies within range of camera to be locken on
var cam_target # Chosen target from cam_targets
# Hit variables
var parrying=false # Controls when parry is active (no damage)
var blocking=false # Controls when block is active (half damage)
var immune=false # Bug fix due to multiple collisions. adds delay between instances of damage
var parry_time=0 # The value used to determine length of parry, is the position of an array
# Cloth variables for controlling the root of the cloth
var bone_idxs=[0,8,83,90,98]
var outer_cloak=[0,8]
var inner_cloak=[83,90,98]
# Menu vars
var menu_open=false # Used to set mouse control when in or out of the menu


func _ready():
	# Sets default mouse mode, means can move camera around
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Makes sure the spring arm for the camera doesn't collide with the player
	$cam_origin_y/cam_origin_x/camera_spring.add_excluded_object(self)
	
	# Adds jiggle bones
	if Global.cloth:
		create_cloak_bones()


func _input(event):
	# Controls when the menu is open closed / when player can move mouse or camera
	if event.is_action_pressed("ui_quit"):
		menu_open=not menu_open
		if menu_open==false:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Controls the rotation of the camera and character controls when in free mode
	if cam_mode == "free" and menu_open==false:
		if event is InputEventMouseMotion:
			cam_pivot_y.rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
			cam_pivot_x.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
			# Clamps camera so that you cant move up and around the players head
			cam_pivot_x.rotation.x = clamp(cam_pivot_x.rotation.x,deg_to_rad(-90),deg_to_rad(45))
	
	# Controls the switching of camera modes
	if event.is_action_pressed("camera_lock"):
		# Makes sure there is a target in range if switching to locked on mode
		if cam_mode=="free" and len(cam_targets)>0:
			cam_target=cam_targets[0]
			cam_mode="fixed"
			# Resets camera rotation
			camera.rotation=Vector3.ZERO
			# Sets animation to start strafing
			animation_tree.set("parameters/cam_lock/transition_request","locked")
		
		elif cam_mode=="fixed":
			cam_mode="free"
			# Sets animation to stop strafing
			animation_tree.set("parameters/cam_lock/transition_request","free")


# Used to set camera to be free in some circumstances
func force_remove_cam_lock():
	if cam_mode=="fixed":
		cam_mode="free"
		animation_tree.set("parameters/cam_lock/transition_request","free")


func _physics_process(delta):
	# Control the roots of the cloth bones
	animate_cloak_roots()
	
	# Accesses the inputs
	input_dir = Input.get_vector("left", "right", "ui_forward", "ui_back")
	
	# Used to control some animations
	if input_dir:
		moving=true
	else:
		moving=false
	
	# Calculates the direction
	direction = (cam_pivot_y.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# If a direction is inputted
	if direction:
		# Controls speeds when sprinting / not
		# Block state has its own speed, so while not blocking
		if state_machine.current_state.name != "block":
			if Input.is_action_pressed("sprint"):
				animation_tree.set("parameters/walk_or_run/transition_request","run")
				speed = 10.0
			else:
				animation_tree.set("parameters/walk_or_run/transition_request","walk")
				speed = 5.0
		
		# Checks if the player should have control over movement in its current state
		if state_machine.check_if_can_move():
			velocity.x = lerp(velocity.x,direction.x*speed,ACCELERATION)
			velocity.z = lerp(velocity.z,direction.z*speed,ACCELERATION)
			target_rotation=atan2(direction.x,direction.z)
			last_direction=direction
		# If not make player sprite look at the direction moving
		else:
			target_rotation=atan2(last_direction.x,last_direction.z)
	
	# If no buttons are pressed, slow down
	else:
		velocity.x = lerp(velocity.x,0.0,ACCELERATION)
		velocity.z = lerp(velocity.z,0.0,ACCELERATION)
	
	# Controls camera movement when locked on
	if cam_mode == "fixed":
		# Calculates camera angles from the player and boss positions
		var cam_tar_vec=cam_target.global_position-global_position+Vector3(0,2,0)
		cam_pivot_y.rotation.y=atan2(cam_tar_vec.x,cam_tar_vec.z)+PI
		
		var hori_dist=sqrt((cam_tar_vec.x)**2+(cam_tar_vec.z)**2)
		cam_pivot_x.rotation.x=-atan2(1.5,hori_dist)
		cam_pivot_x.rotation.x=clamp(cam_pivot_x.rotation.x,-0.7,-0.2)
		
		# Probably to fix some bug 
		$cam_origin_y/cam_origin_x/camera_spring/cam_rotation_target.look_at(
			cam_target.global_position)
		var target_rot=$cam_origin_y/cam_origin_x/camera_spring/cam_rotation_target.rotation
		# Makes camera movement smoother
		camera.rotation = lerp(camera.rotation,target_rot,0.3)
		
		# When in dash sprite rotation follows vel, so exept when dashing 
		if state_machine.current_state.name !="dash":
			# Overides previous target_rotation if locked on to look straight ahead.
			target_rotation=atan2(cam_tar_vec.x,cam_tar_vec.z)
	
	# Smoothly points sprite at the desired angle
	sprite.rotation.y=lerp_angle(sprite.rotation.y,target_rotation,SPRITE_TURN_SPEED*delta)
	
	# Used to control some animations
	if Input.is_action_pressed("sprint"):
		running=true
	else:
		running=false
	
	# Update positions and such
	move_and_slide()


# Controls jump animation
func jump():
	if jump_spam_fix==false:
		jump_spam_fix=true
		animation_tree.set("parameters/state/transition_request","air")
		animation_tree.set("parameters/jump_and_fall/transition_request","jump")
		$timers/jump_delay.start()


# Adds delay to start jump movement for more realistic animations
func _on_jump_delay_timeout():
	velocity.y = JUMP_VELOCITY
	jump_spam_fix=false


# Once dash cooldown finishes, can dash again
func _on_dash_cooldown_timeout():
	can_dash = true


# Clears jump buffer
func _on_input_buffer_time_timeout():
	wants_to_jump = false


# Adds jigglebones to cloth
func create_cloak_bones():
	for i in range(len(cloak_bones)):
		var cloak_bone=cloak_bone_scene.instantiate()
		cloak_bone.bone_name=cloak_bones[i]
		cloak_bone.forward_axis=4
		$player_model/Sekiro_like_player_character/Armature/GeneralSkeleton.add_child(cloak_bone)


# Controls the roots of the cloth bones to make them move more pronounced
func animate_cloak_roots():
	# Default cloth calc
	var cloak_rot=(0.01*PI*velocity.length())
	# Controls the different options for moving cloth, eg when running should flap up more than 
	# When walking
	var options=[[3,-0.7],[2,-0.25],[1,1]]
	var fix
	if (running==true and state_machine.current_state.name == "ground"):
		fix=options[0]
		if cam_mode=="fixed" and input_dir.y>0:
			fix=options[2]
	elif state_machine.current_state.name == "dash":
		fix=options[1]
	else:
		fix=options[2]
	
	# Sets calculated rotation to cloth roots
	var quat_rot=Quaternion(Vector3(1,0,0),fix[0]*cloak_rot)
	var cloak_fix=Quaternion(Vector3(1,0,0),fix[1]*cloak_rot)
	for i in range(2):
		$player_model/Sekiro_like_player_character/Armature/GeneralSkeleton.set_bone_pose_rotation(
			outer_cloak[i],quat_rot)
	for i in range(3):
		$player_model/Sekiro_like_player_character/Armature/GeneralSkeleton.set_bone_pose_rotation(
			inner_cloak[i],cloak_fix)


# Controls which objects are in camera range (can be done better)
func _on_cam_target_finder_body_entered(body):
	if body != self and body.is_in_group("enemy"):
		cam_targets.append(body)


func _on_cam_target_finder_body_exited(body):
	if body != self and body.is_in_group("enemy"):
		cam_targets.erase(body)


# Enemy hits player
func _on_area_3d_area_entered(area):
	# Only runs if player can be hit
	if immune==false:
		# Controls camera shake
		camera.add_trauma(0.3)
		
		# Makes it so player cant be hit again right away
		immune=true 
		$timers/immunity_timer.wait_time=0.1*Global.boss_speed
		$timers/immunity_timer.start()
		
		# Resets parry length (number is position of array)
		parry_time=0
		
		# Controls knockback
		var vel = (global_position-boss.global_position).normalized()*3
		vel.y=-10
		var t=get_tree().create_tween()
		t.tween_property(self,"velocity",vel,0.2
		).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
		# Checks the possible conditions that can happen when the player is hit
		# Controls animation for each case
		if parrying==true:
			animation_tree.set("parameters/parry_transition/transition_request","parry")
			# Adds delay after successful parry for animation to play
			state_machine.current_state.succ_parry()
			
			# Deletes shield when successful parry
			var parry_effects=sprite.get_node("shield_spawn").get_children()
			for effect in parry_effects:
				effect.parry()
			
			# Adds sound effect for parry
			var sfx=sound_effect_scene.instantiate()
			sfx.play_sound(parry_sounds.pick_random(),0)
			$sounds.add_child(sfx)
			
			# Adds particles for parry
			var particles=parry_particle_var.instantiate()
			particles.emitting=true
			particles.process_material.color=Color.GOLD
			particles.process_material.color.a=0.2
			sprite.get_node("shield_spawn").add_child(particles)
		
		# Controls blocking, changes animation, halves damage
		elif blocking==true:
			animation_tree.set("parameters/parry_transition/transition_request","block_hit")
			Global.player_health-=Global.boss_current_attack_damage*0.5
		
		# When not defending, damage particles, full damage
		elif parrying==false and blocking==false:
			var particles=parry_particle_var.instantiate()
			particles.emitting=true
			particles.process_material.color=Color.RED
			$particles.add_child(particles)
			Global.player_health-=Global.boss_current_attack_damage*1.0
	
	# Check if ebough damage to be dead
	if Global.player_health<=0:
		state_machine.current_state.next_state=dead_state_var


# Resets immunity
func _on_immunity_timer_timeout():
	immune=false


# Adds shield parry effect
func shield_up():
	var shield=shield_scene.instantiate()
	sprite.get_node("shield_spawn").add_child(shield)


# Controls sounds when attacking
func play_attack_sound():
	var sfx=sound_effect_scene.instantiate()
	sfx.play_sound(swing_sounds.pick_random(),-10)
	$sounds.add_child(sfx)


# Fixes issue where block animation wouldn't play if hit multiple times in a row
func _on_animation_tree_animation_finished(anim_name):
	if anim_name=="block_hit":
		animation_tree.set("parameters/parry_transition/transition_request","block_loop")
