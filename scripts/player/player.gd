extends CharacterBody3D


# constants

const ACCELERATION = 0.2
const SPRITE_TURN_SPEED = 12
const JUMP_VELOCITY = 8




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
@onready var boss=get_parent().get_node("boss_1")


@export var parry_particle_var : PackedScene
@export var staggered_state_var : State
@export var dead_state_var : State
@export var shield_scene : PackedScene
var sensitivity = 0.1

@onready var cloak_bones = [
	"cloak_2_O.R","cloak_3_O.R","cloak_4_O.R","cloak_5_O.R","cloak_6_O.R","cloak_7_O.R",
	"cloak_2_O.L","cloak_3_O.L","cloak_4_O.L","cloak_5_O.L","cloak_6_O.L","cloak_7_O.L",
	"cloak_2_I.R","cloak_3_I.R","cloak_4_I.R","cloak_5_I.R","cloak_6_I.R","cloak_7_I.R",
	"cloak_2_I.L","cloak_3_I.L","cloak_4_I.L","cloak_5_I.L","cloak_6_I.L","cloak_7_I.L",
	"cloak_mid_2","cloak_mid_3","cloak_mid_4","cloak_mid_5","cloak_mid_6","cloak_mid_7",
	]
@export var cloak_bone_scene : PackedScene


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# variables accessed by state machine and player
var direction=Vector3.ZERO
var last_direction=Vector3.ZERO
var can_dash = true
var wants_to_jump = false
var speed = 10.0
var moving=false
var target_rotation=0.0
var input_dir
var running=false
var cam_mode="free"
var cam_targets=[]
var cam_target

var parrying=false
var blocking=false
var immune=false
var parry_time=0

var bone_idxs=[0,8,83,90,98]
var outer_cloak=[0,8]
var inner_cloak=[83,90,98]

var jump_spam_fix=false
var menu_open=false

func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# makes sure the spring arm for the camera doesn't collide with the player
	$cam_origin_y/cam_origin_x/camera_spring.add_excluded_object(self)
	
	# adds jiggle bones
	create_cloak_bones()




func _input(event):
	if event.is_action_pressed("ui_quit"):
		menu_open=not menu_open
		if menu_open==false:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# controls the rotation of the camera and character controls
	if cam_mode == "free" and menu_open==false:
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

func force_remove_cam_lock():
	if cam_mode=="fixed":
		cam_mode="free"
		animation_tree.set("parameters/cam_lock/transition_request","free")



func _physics_process(delta):
	animate_cloak_roots()
	# accesses the inputs
	input_dir = Input.get_vector("left", "right", "ui_forward", "ui_back")
	
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
				animation_tree.set("parameters/walk_or_run/transition_request","run")
				speed = 10.0
				
			else:
				animation_tree.set("parameters/walk_or_run/transition_request","walk")
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
		cam_pivot_x.rotation.x=clamp(cam_pivot_x.rotation.x,-0.7,-0.2)
		#cam_pivot_x.rotation.x=-PI/6
		
		$cam_origin_y/cam_origin_x/camera_spring/cam_rotation_target.look_at(cam_target.global_position)
		var target_rot=$cam_origin_y/cam_origin_x/camera_spring/cam_rotation_target.rotation
		camera.rotation = lerp(camera.rotation,target_rot,0.3)
		
		if state_machine.current_state.name !="dash":
			target_rotation=atan2(cam_tar_vec.x,cam_tar_vec.z)
			
	
	sprite.rotation.y=lerp_angle(sprite.rotation.y,target_rotation,SPRITE_TURN_SPEED*delta)
	
	
	if Input.is_action_pressed("sprint"):
		running=true
	else:
		running=false
	
	
	
	move_and_slide()


func jump():
	if jump_spam_fix==false:
		jump_spam_fix=true
		animation_tree.set("parameters/state/transition_request","air")
		animation_tree.set("parameters/jump_and_fall/transition_request","jump")
		$timers/jump_delay.start()

func _on_jump_delay_timeout():
	velocity.y = JUMP_VELOCITY
	jump_spam_fix=false

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
	
	
	var quat_rot=Quaternion(Vector3(1,0,0),fix[0]*cloak_rot)
	var cloak_fix=Quaternion(Vector3(1,0,0),fix[1]*cloak_rot)
	for i in range(2):
		$player_model/Sekiro_like_player_character/Armature/GeneralSkeleton.set_bone_pose_rotation(outer_cloak[i],quat_rot)
	for i in range(3):
		$player_model/Sekiro_like_player_character/Armature/GeneralSkeleton.set_bone_pose_rotation(inner_cloak[i],cloak_fix)
	










func _on_cam_target_finder_body_entered(body):
	if body != self and body.is_in_group("enemy"):
		cam_targets.append(body)


func _on_cam_target_finder_body_exited(body):
	if body != self and body.is_in_group("enemy"):
		cam_targets.erase(body)



# enemy hits player
func _on_area_3d_area_entered(area):
	if immune==false:
		camera.add_trauma(0.3)
		immune=true
		parry_time=0
		$timers/immunity_timer.start()
		var vel = (global_position-boss.global_position).normalized()*3
		vel.y=-10
		var t=get_tree().create_tween()
		t.tween_property(self,"velocity",vel,0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		if parrying==true:
			var parry_effects=sprite.get_node("shield_spawn").get_children()
			for effect in parry_effects:
				effect.parry()
			state_machine.current_state.succ_parry()
			var particles=parry_particle_var.instantiate()
			particles.emitting=true
			particles.process_material.color=Color.GOLD
			particles.process_material.color.a=0.2
			sprite.get_node("shield_spawn").add_child(particles)
			animation_tree.set("parameters/parry_transition/transition_request","parry")
		elif blocking==true:
			print("block")
			animation_tree.set("parameters/parry_transition/transition_request","block_hit")
			Global.player_health-=Global.boss_current_attack_damage*0.5
		elif parrying==false and blocking==false:
			print("hit")
			var particles=parry_particle_var.instantiate()
			particles.emitting=true
			particles.process_material.color=Color.RED
			$particles.add_child(particles)
			Global.player_health-=Global.boss_current_attack_damage*1.0
	
	if Global.player_health<=0:
		state_machine.current_state.next_state=dead_state_var
	


func _on_immunity_timer_timeout():
	immune=false


func shield_up():
	var shield=shield_scene.instantiate()
	sprite.get_node("shield_spawn").add_child(shield)





func _on_animation_tree_animation_finished(anim_name):
	if anim_name=="block_hit":
		animation_tree.set("parameters/parry_transition/transition_request","block_loop")


