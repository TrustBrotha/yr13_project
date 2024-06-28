extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var looking = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_pos
@onready var player = get_parent().get_node("player")


func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if looking == true:
		face_player(delta)

func _on_attack_timer_timeout():
	$AnimationPlayer.play("vertical_swing")

func face_player(delta):
	var direction = global_position-player.global_position
	rotation.y=lerp_angle(rotation.y,atan2(direction.x,direction.z)+PI,4*delta)
	
	#rotation.y=atan2(direction.x,direction.z)+PI
	#rotation.y=move_toward(rotation.y,atan2(direction.x,direction.z)+PI,8*delta)

func start_looking():
	looking = true

func stop_looking():
	looking = false


func _on_weapon_detect_area_entered(area):
	if area.is_in_group("parry_collision"):
		$AnimationPlayer.play("parried")
		$parry_forgiveness.start()


func _on_parry_forgiveness_timeout():
	$Node3D/weapon_damage/weapon_damage_coll.disabled = false



