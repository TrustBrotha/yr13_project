extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var move_to_player=true
@export var beam_scene : PackedScene

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target : Vector3
@onready var player = get_parent().get_node("player")


func _ready():
	$boss_1_model/AnimationPlayer.play("test_pose")

func _input(event):
	if event.is_action_pressed("enter"):
		move_to_player=false
		velocity=Vector3.ZERO
		smash_attack()

func _physics_process(delta):
	var direction = global_position-player.global_position
	rotation.y=lerp_angle(rotation.y,atan2(direction.x,direction.z)+PI,8*delta)
	
	if move_to_player == true:
		var vel=(player.global_position-global_position).normalized()*2
		velocity.x=vel.x
		velocity.z=vel.z
		if not is_on_floor():
			velocity.y -= gravity * delta
	
	target=player.global_position+(global_position-player.global_position).normalized()*2
	target.y=player.global_position.y
	
	
	move_and_slide()


func animate_cloak_roots():
	var cloak_rot=(0.01*PI*velocity.length())
	var quat_rot=Quaternion(Vector3(1,0,0),cloak_rot)
	var bone_idxs=[42,49,56,63]
	for i in range(4):
		$boss_1_model/Armature/Skeleton3D.set_bone_pose_rotation(bone_idxs[i],quat_rot)







func smash_attack():
	position.y=6.0
	var beam_pos =[Vector3(2,2,0),Vector3(-2,2,0)]
	for i in range(2):
		var laser = beam_scene.instantiate()
		laser.position=beam_pos[i]
		$beams.add_child(laser)
	
	$boss_1_model/AnimationPlayer.play("attack_fly_slam")

func smash():
	var t=get_tree().create_tween()
	t.tween_property(self,"global_position",target,0.3)

func attack_finished():
	$boss_1_model/AnimationPlayer.play("test_pose")
	move_to_player=true
