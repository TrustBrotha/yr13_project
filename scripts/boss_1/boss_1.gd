extends CharacterBody3D

const SPEED = 5
#const JUMP_VELOCITY = 4.5

#var move_to_player=true
@export var animation_tree : AnimationTree
@export var state_machine : Node
@export var blank_state_var : State
@export var attack_state_var : State
@export var parry_particle_var : PackedScene
@export var weapon_coll : CollisionShape3D
@export var cloak_bone_scene : PackedScene
#@onready var cloak_bones = [
	#"cloak_outer_2.L","cloak_outer_3.L","cloak_outer_4.L","cloak_outer_5.L","cloak_outer_6.L","cloak_outer_7.L",
	#"cloak_inner_2.L","cloak_inner_3.L","cloak_inner_4.L","cloak_inner_5.L","cloak_inner_6.L","cloak_inner_7.L",
	#"cloak_outer_2.R","cloak_outer_3.R","cloak_outer_4.R","cloak_outer_5.R","cloak_outer_6.R","cloak_outer_7.R",
	#"cloak_inner_2.R","cloak_inner_3.R","cloak_inner_4.R","cloak_inner_5.R","cloak_inner_6.R","cloak_inner_7.R",
	#"cloak_front_1","cloak_front_2","cloak_front_3","cloak_back_1","cloak_back_2",
	#]
@onready var cloak_bones = [
	"cloak_outer_2.L","cloak_outer_3.L","cloak_outer_5.L","cloak_outer_7.L",
	"cloak_inner_2.L","cloak_inner_3.L","cloak_inner_5.L","cloak_inner_7.L",
	"cloak_outer_2.R","cloak_outer_3.R","cloak_outer_5.R","cloak_outer_7.R",
	"cloak_inner_2.R","cloak_inner_3.R","cloak_inner_5.R","cloak_inner_7.R",
	"cloak_front_2","cloak_front_3","cloak_back_2",
	]
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var attack_range=3.5
#var target : Vector3
@onready var player = get_parent().get_node("player")

var attacking=false
#var can_attack=true

var player_relative_location


var immune=false
var blocking=false
var block_prepared=false
var block_recov=false

var wants_to_chase=false

var half_health_attack_done=false
func _ready():
	create_cloak_bones()


func create_cloak_bones():
	for i in range(len(cloak_bones)):
		var cloak_bone=cloak_bone_scene.instantiate()
		cloak_bone.bone_name=cloak_bones[i]
		cloak_bone.stiffness=0.3
		cloak_bone.forward_axis=4
		$boss_1_model/Armature/GeneralSkeleton.add_child(cloak_bone)

func _physics_process(delta):
	animate_cloak_roots()
	player_relative_location=player.global_position-global_position
	
	var direction = global_position-player.global_position
	rotation.y=atan2(direction.x,direction.z)+PI
	

	animation_tree.set(
		"parameters/block_blend/blend_amount",
		lerp(animation_tree.get("parameters/block_blend/blend_amount"),
		0.0,0.1))
	if half_health_attack_done==false:
		if Global.boss_health<500:
			half_health_attack_done=true
			laser_attack(6,2)
	
	move_and_slide()


func animate_cloak_roots():
	var cloak_rot=(0.01*PI*velocity.length())
	var quat_rot=Quaternion(Vector3(1,0,0),cloak_rot)
	var bone_idxs=[42,49,56,63]
	for i in range(4):
		$boss_1_model/Armature/GeneralSkeleton.set_bone_pose_rotation(bone_idxs[i],quat_rot)







func laser_attack(gap_time,beam_type):
	state_machine.current_state.next_state=blank_state_var
	animation_tree.set("parameters/state/transition_request","attack")
	animation_tree.set("parameters/attacks/transition_request","attack_fly_up")
	await get_tree().create_timer(0.25).timeout 
	var t=get_tree().create_tween()
	t.tween_property(self,"global_position",global_position+Vector3(0,6,0),0.45).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	get_parent().spawn_beams(beam_type)
	
	await get_tree().create_timer(gap_time).timeout
	animation_tree.set("parameters/attacks/transition_request","attack_fly_slam")
	weapon_coll.disabled=false
	await get_tree().create_timer(0.4).timeout 
	var target=player.global_position+(global_position-player.global_position).normalized()*2.5
	target.y=player.global_position.y
	var t2=get_tree().create_tween()
	t2.tween_property(self,"global_position",target,0.45).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.5).timeout
	weapon_coll.disabled=true
	await get_tree().create_timer(0.2).timeout
	state_machine.current_state.next_state=attack_state_var











func _on_area_3d_area_entered(area):
	if immune==false:
		player.camera.add_trauma(0.1)
		immune=true
		$timers/immunity_timer.start()
		if attacking==false:
			var vel = (transform.basis * Vector3(0, 0, -1)).normalized()*3
			var t=get_tree().create_tween()
			t.tween_property(self,"velocity",vel,0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
		if blocking==true:
			animation_tree.set("parameters/block_blend/blend_amount",1.0)
			Global.boss_health-=Global.player_attack_damage*0.5
		elif blocking==false:
			var particles=parry_particle_var.instantiate()
			particles.emitting=true
			particles.process_material.color=Color.RED
			$particles.add_child(particles)
			Global.boss_health-=Global.player_attack_damage*1.0
	
	if Global.boss_health <=0:
		state_machine.current_state.next_state=blank_state_var


func _on_immunity_timer_timeout():
	immune=false
