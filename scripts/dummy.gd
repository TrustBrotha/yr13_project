extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var looking = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_pos
@onready var player = get_parent().get_node("player")


func _physics_process(delta):
	velocity+=(get_parent().get_node("player").global_position-global_position).normalized()*0.8
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	face_player(delta)
	
	move_and_slide()



func face_player(delta):
	var direction = global_position-player.global_position
	rotation.y=lerp_angle(rotation.y,atan2(direction.x,direction.z)+PI,6*delta)
	
	#rotation.y=atan2(direction.x,direction.z)+PI
	#rotation.y=move_toward(rotation.y,atan2(direction.x,direction.z)+PI,8*delta)
