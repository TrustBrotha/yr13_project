extends CharacterBody3D


# constants

const ACCELERATION = 0.2
const SPRITE_TURN_SPEED = 12
const JUMP_VELOCITY = 10


signal parry_done


# defines the state machine to me manipulated as a variable
@onready var state_machine : CharacterStateMachine = $character_state_machine

# preloaded nodes to be accessed by state machine
@onready var cam_pivot_x = $cam_origin_y/cam_origin_x
@onready var cam_pivot_y = $cam_origin_y
@onready var camera = $cam_origin_y/cam_origin_x/camera_spring/Camera3D
@onready var sprite = $player_model
@onready var timers = $timers
@onready var animation_player = $player_model/Sekiro_like_player_character/AnimationPlayer
@onready var animation_tree = $player_model/Sekiro_like_player_character/AnimationTree

@export var parry_particle_var : PackedScene
@export var staggered_state_var : State

var sensitivity = 0.1

@onready var cloak_bones = [
	"cloak_2_O.R","cloak_3_O.R","cloak_4_O.R","cloak_5_O.R","cloak_6_O.R","cloak_7_O.R",
	"cloak_2_O.L","cloak_3_O.L","cloak_4_O.L","cloak_5_O.L","cloak_6_O.L","cloak_7_O.L",
	"cloak_2_I.R","cloak_3_I.R","cloak_4_I.R","cloak_5_I.R","cloak_6_I.R","cloak_7_I.R",
	"cloak_2_I.L","cloak_3_I.L","cloak_4_I.L","cloak_5_I.L","cloak_6_I.L","cloak_7_I.L",
	"cloak_mid_2","cloak_mid_3","cloak_mid_4","cloak_mid_5","cloak_mid_6","cloak_mid_7"]
@export var cloak_bone_scene : PackedScene


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# variables accessed by state machine and player
var direction=Vector3.ZERO
var last_direction=Vector3.ZERO
var can_dash = true
var wants_to_jump = false
var health = 1000
var speed = 10.0
var moving=false
var target_rotation=0.0
var input_dir

var cam_mode="free"
var cam_targets=[]
var cam_target

var parrying=false
var blocking=false
var immune=false

func _ready():
	# gets the mouse actions
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# makes sure the spring arm for the camera doesn't collide with the player
	$cam_origin_y/cam_origin_x/camera_spring.add_excluded_object(self)
	
	# adds jiggle bones
	create_cloak_bones()


func _input(event):
	# controls the rotation of the camera and character controls
	if cam_mode == "free":
		if event is InputEventMouseMotion:
			cam_pivot_y.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
			cam_pivot_x.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
			# clamps camera so that you cant move up and around the players head
			cam_pivot_x.rotation.x = clamp(cam_pivot_x.rotation.x,deg_to_rad(-90),deg_to_rad(45))
	
	
	if event.is_action_pressed("camera_lock"):
		if cam_mode=="free" and len(cam_targets)>0:
			cam_target=cam_targets[0]
			cam_mode="fixed"
			camera.rotation=Vector3.ZERO
			animation_tree.set("parameters/cam_lock/transition_request","locked")
		elif cam_mode=="fixed":
			cam_mode="free"
			animation_tree.set("parameters/cam_lock/transition_request","free")



func _physics_process(delta):
	#print(animation_tree.get("parameters/cam_lock/current_state"))
	animate_cloak_roots()
	
	# quits game (as mouse is used cant go to x button)
	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()
	
	# accesses the inputs
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_forward", "ui_back")
	
	if input_dir:
		moving=true
	else:
		moving=false
	
	# calculates the direction
	direction = (cam_pivot_y.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# if a direction is inputted
	if direction:
		# controls sprinting
		if state_machine.current_state.name != "block":
			if Input.is_action_pressed("sprint"):
				speed = 10.0
			else:
				speed = 5.0
		
		
		# checks if the player should have control over movement in its current state
		if state_machine.check_if_can_move():
			velocity.x = lerp(velocity.x,direction.x*speed,ACCELERATION)
			velocity.z = lerp(velocity.z,direction.z*speed,ACCELERATION)
			target_rotation=atan2(direction.x,direction.z)
			last_direction=direction
		else:
			target_rotation=atan2(last_direction.x,last_direction.z)
	
	# if no buttons are pressed
	else:
		velocity.x = lerp(velocity.x,0.0,ACCELERATION)
		velocity.z = lerp(velocity.z,0.0,ACCELERATION)
	
	
	if cam_mode == "fixed":
		var cam_tar_vec=cam_target.global_position-global_position+Vector3(0,2,0)
		cam_pivot_y.rotation.y=atan2(cam_tar_vec.x,cam_tar_vec.z)+PI
		
		var hori_dist=sqrt((cam_tar_vec.x)**2+(cam_tar_vec.z)**2)
		cam_pivot_x.rotation.x=-atan2(1.5,hori_dist)
		#cam_pivot_x.rotation.x=-PI/6
		
		$cam_origin_y/cam_origin_x/camera_spring/cam_rotation_target.look_at(cam_target.global_position)
		var target_rot=$cam_origin_y/cam_origin_x/camera_spring/cam_rotation_target.rotation
		camera.rotation = lerp(camera.rotation,target_rot,0.3)
		
		target_rotation=atan2(cam_tar_vec.x,cam_tar_vec.z)
	
	sprite.rotation.y=lerp_angle(sprite.rotation.y,target_rotation,SPRITE_TURN_SPEED*delta)
	
	
	
	
	
	
	
	
	
	
	move_and_slide()






# once dash cooldown finishes, can dash again
func _on_dash_cooldown_timeout():
	can_dash = true

# clears buffer
func _on_input_buffer_time_timeout():
	wants_to_jump = false






func create_cloak_bones():
	for i in range(len(cloak_bones)):
		var cloak_bone=cloak_bone_scene.instantiate()
		cloak_bone.bone_name=cloak_bones[i]
		cloak_bone.forward_axis=4
		$player_model/Sekiro_like_player_character/Armature/GeneralSkeleton.add_child(cloak_bone)


func animate_cloak_roots():
	var cloak_rot=(0.01*PI*velocity.length())
	var quat_rot=Quaternion(Vector3(1,0,0),cloak_rot)
	var bone_idxs=[0,8,83,90,98]
	for i in range(5):
		$player_model/Sekiro_like_player_character/Armature/GeneralSkeleton.set_bone_pose_rotation(bone_idxs[i],quat_rot)










func _on_cam_target_finder_body_entered(body):
	if body != self and body.is_in_group("enemy"):
		cam_targets.append(body)


func _on_cam_target_finder_body_exited(body):
	if body != self and body.is_in_group("enemy"):
		cam_targets.erase(body)



# enemy hits player
func _on_area_3d_area_entered(area):
	if immune==false:
		immune=true
		$timers/immunity_timer.start()
		if parrying==true:
			var particles=parry_particle_var.instantiate()
			particles.emitting=true
			particles.process_material.color=Color.WHITE
			$particles.add_child(particles)
			animation_tree.set("parameters/parry_transition/blend_amount",1.0)
		elif blocking==true:
			var particles=parry_particle_var.instantiate()
			particles.emitting=true
			particles.process_material.color=Color.YELLOW
			$particles.add_child(particles)
			animation_tree.set("parameters/parry_transition/blend_amount",1.0)
		elif parrying==false and blocking==false:
			var particles=parry_particle_var.instantiate()
			particles.emitting=true
			particles.process_material.color=Color.RED
			$particles.add_child(particles)
		print("hit")


func _on_immunity_timer_timeout():
	immune=false
