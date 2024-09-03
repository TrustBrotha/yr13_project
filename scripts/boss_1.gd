extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var move_to_player=true
@export var beam_scene : PackedScene

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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
		velocity=(player.global_position-global_position).normalized()*4
		if not is_on_floor():
			velocity.y -= gravity * delta
	
	move_and_slide()



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
	var target=player.global_position+(global_position-player.global_position).normalized()*2
	target.y=player.global_position.y
	#$CSGMesh3D2.global_position=target
	t.tween_property(self,"global_position",target,0.3)

func attack_finished():
	$boss_1_model/AnimationPlayer.play("test_pose")
	move_to_player=true
