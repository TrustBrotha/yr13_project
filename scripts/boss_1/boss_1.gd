extends CharacterBody3D

const SPEED = 5.0
#const JUMP_VELOCITY = 4.5

#var move_to_player=true
@export var beam_scene : PackedScene
@export var animation_tree : AnimationTree
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var attack_range=2.0
#var target : Vector3
@onready var player = get_parent().get_node("player")

#var attacking=false
#var can_attack=true

var player_relative_location


func _ready():
	pass
	#$boss_1_model/AnimationPlayer.play("test_pose")

#func _input(event):
	#if event.is_action_pressed("enter"):
		#move_to_player=false
		#can_attack=false
		#velocity=Vector3.ZERO
		#smash_attack()

func _physics_process(delta):
	
	player_relative_location=player.global_position-global_position
	
	var direction = global_position-player.global_position
	rotation.y=atan2(direction.x,direction.z)+PI
	
	#if move_to_player == true && (player.global_position-global_position).length()>2.0:
		#var vel=(player.global_position-global_position).normalized()*2
		#velocity.x=vel.x
		#velocity.z=vel.z
		#if not is_on_floor():
			#velocity.y -= gravity * delta
	#else:
		#velocity=lerp(velocity,Vector3.ZERO,0.3)
	#
	#target=player.global_position+(global_position-player.global_position).normalized()*2.5
	#target.y=player.global_position.y
	
	#if attacking==false && can_attack==true:
		#if (player.global_position-global_position).length()<2.5:
			#attacking=true
			#can_attack=false
			#move_to_player=false
			#basic_attack()
	
	
	move_and_slide()


func animate_cloak_roots():
	var cloak_rot=(0.01*PI*velocity.length())
	var quat_rot=Quaternion(Vector3(1,0,0),cloak_rot)
	var bone_idxs=[42,49,56,63]
	for i in range(4):
		$boss_1_model/Armature/Skeleton3D.set_bone_pose_rotation(bone_idxs[i],quat_rot)







#func basic_attack():
	#velocity=(player.global_position-global_position).normalized()*1.0
	##var t=get_tree().create_tween()
	##t.tween_property(self,"velocity",(player.global_position-global_position).normalized()*6.0,0.6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	#var r =randi_range(0,1)
	#if r==1:
		#$boss_1_model/AnimationTree.set("parameters/state/transition_request","attack_1")
	#else:
		#$boss_1_model/AnimationTree.set("parameters/state/transition_request","attack_2")




#func smash_attack():
	#var beam_pos =[Vector3(7,7,-15),Vector3(-7,7,-15)]
	#var offset_options = [-1.2,1.2]
	#for i in range(2):
		#var laser = beam_scene.instantiate()
		#laser.position=beam_pos[i]
		#laser.offset=offset_options[i]
		#$beams.add_child(laser)
	#
	#$boss_1_model/AnimationTree.set("parameters/state/transition_request","smash_attack")
#
#
#
#func fly():
	#var t=get_tree().create_tween()
	#t.tween_property(self,"global_position",global_position+Vector3(0,6,0),0.45).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
#
#func smash():
	#var t=get_tree().create_tween()
	#t.tween_property(self,"global_position",target,0.45).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
#
#
#
#
#
#func attack_finished():
	#print("hi")
	#$boss_1_model/AnimationTree.set("parameters/state/transition_request","walk")
	#attacking=false
	#move_to_player=true
	#$timers/attack_cooldown.start()







#func _on_attack_cooldown_timeout():
	#can_attack=true
