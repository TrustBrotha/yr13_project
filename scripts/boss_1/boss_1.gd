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


func _ready():
	pass

func _input(event):
	if event.is_action_pressed("enter"):
		laser_attack()

func _physics_process(delta):
	print(state_machine.current_state.name)
	#print(state_machine.current_state.name)
	player_relative_location=player.global_position-global_position
	
	var direction = global_position-player.global_position
	rotation.y=atan2(direction.x,direction.z)+PI
	

	animation_tree.set(
		"parameters/block_blend/blend_amount",
		lerp(animation_tree.get("parameters/block_blend/blend_amount"),
		0.0,0.1))
	
	
	move_and_slide()


func animate_cloak_roots():
	var cloak_rot=(0.01*PI*velocity.length())
	var quat_rot=Quaternion(Vector3(1,0,0),cloak_rot)
	var bone_idxs=[42,49,56,63]
	for i in range(4):
		$boss_1_model/Armature/Skeleton3D.set_bone_pose_rotation(bone_idxs[i],quat_rot)







func laser_attack():
	state_machine.current_state.next_state=blank_state_var
	animation_tree.set("parameters/state/transition_request","attack")
	animation_tree.set("parameters/attacks/transition_request","attack_fly_up")
	await get_tree().create_timer(0.25).timeout 
	var t=get_tree().create_tween()
	t.tween_property(self,"global_position",global_position+Vector3(0,6,0),0.45).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	get_parent().spawn_beams()
	
	await get_tree().create_timer(2).timeout
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
		immune=true
		$timers/immunity_timer.start()
		
		if attacking==false:
			var vel = (transform.basis * Vector3(0, 0, -1)).normalized()*3
			var t=get_tree().create_tween()
			t.tween_property(self,"velocity",vel,0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
		if blocking==true:
			#var particles=parry_particle_var.instantiate()
			#particles.emitting=true
			#particles.process_material.color=Color.YELLOW
			#$particles.add_child(particles)
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
