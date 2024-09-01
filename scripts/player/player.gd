extends CharacterBody3D


# constants

const ACCELERATION = 0.2
const SPRITE_TURN_SPEED = 12
const JUMP_VELOCITY = 10


signal parry_done


# defines the state machine to me manipulated as a variable
@onready var state_machine : CharacterStateMachine = $character_state_machine

# preloaded nodes
@onready var cam_pivot_x = $cam_origin_y/cam_origin_x
@onready var cam_pivot_y = $cam_origin_y
@onready var camera = $cam_origin_y/cam_origin_x/camera_spring/Camera3D
@onready var sprite = $player_model
@onready var timers = $timers
@onready var animation_player = $player_model/Sekiro_like_player_character/AnimationPlayer
@onready var animation_tree = $player_model/Sekiro_like_player_character/AnimationTree
@export var staggered_state_var : State
var sensitivity = 0.1



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


func _ready():
	
	# gets the mouse actions
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# makes sure the spring arm for the camera doesn't collide with the player
	$cam_origin_y/cam_origin_x/camera_spring.add_excluded_object(self)

func _input(event):
	# controls the rotation of the camera and character controls
	if event is InputEventMouseMotion:
		cam_pivot_y.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		cam_pivot_x.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		# clamps camera so that you cant move up and around the players head
		cam_pivot_x.rotation.x = clamp(cam_pivot_x.rotation.x,deg_to_rad(-90),deg_to_rad(45))


func lock_cam_target():
	pass
	


func _physics_process(delta):
	# quits game (as mouse is used cant go to x button)
	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()
	
	
	
	# accesses the inputs
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_forward", "ui_back")
	if input_dir:
		moving=true
		
	else:
		moving=false
	
	# calculates the direction
	direction = (cam_pivot_y.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	# if a direction is inputted
	if direction:
		# controls sprinting
		if Input.is_action_pressed("sprint") and is_on_floor():
			speed = 20.0
		else:
			speed = 10.0
	
		# checks if the player should have control over movement in its current state
		if state_machine.check_if_can_move():
			velocity.x = lerp(velocity.x,direction.x*speed,ACCELERATION)
			velocity.z = lerp(velocity.z,direction.z*speed,ACCELERATION)
			target_rotation=atan2(direction.x,direction.z)
		else:
			target_rotation=atan2(last_direction.x,last_direction.z)
		
	# if no buttons are pressed
	else:
		velocity.x = lerp(velocity.x,0.0,ACCELERATION)
		velocity.z = lerp(velocity.z,0.0,ACCELERATION)
	
	
	sprite.rotation.y=lerp_angle(sprite.rotation.y,target_rotation,SPRITE_TURN_SPEED*delta)
	
	move_and_slide()

# once dash cooldown finishes, can dash again
func _on_dash_cooldown_timeout():
	can_dash = true

# clears buffer
func _on_input_buffer_time_timeout():
	wants_to_jump = false

func get_last_direction():
	last_direction=direction










