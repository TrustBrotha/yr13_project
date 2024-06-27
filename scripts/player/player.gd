extends CharacterBody3D


# constants
const SPEED = 10.0
const ACCELERATION = 0.2
const SPRITE_TURN_SPEED = 8
const JUMP_VELOCITY = 10

# defines the state machine to me manipulated as a variable
@onready var state_machine : CharacterStateMachine = $character_state_machine

# preloaded nodes
@onready var cam_pivot_x = $cam_origin_y/cam_origin_x
@onready var cam_pivot_y = $cam_origin_y
@onready var sprite = $player_asset
@onready var timers = $timers
#@onready var dash_timer = $timers/dash_time
#@onready var dash_cooldown = $timers/dash_cooldown


@export var sensitivity = 0.3
@export var vel_tolerance = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# variables accessed by state machine and player
var direction
var sprite_lock = false
var can_dash = true
var wants_to_jump = false


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
		cam_pivot_x.rotation.x = clamp(cam_pivot_x.rotation.x,deg_to_rad(-90),
		deg_to_rad(45))



func _physics_process(delta):
	# quits game (as mouse is used cant go to x button)
	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()
	
	# accesses whether should rotate the sprite with the inputs or not
	sprite_lock = state_machine.check_sprite_lock()
	# accesses the inputs
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_forward", "ui_back")
	# calculates the direction
	direction = (cam_pivot_y.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# if buttons are pressed
	if direction:
		# checks if the player should be able to move in its current state
		if state_machine.check_if_can_move():
			velocity.x = lerp(velocity.x,direction.x*SPEED,ACCELERATION)
			velocity.z = lerp(velocity.z,direction.z*SPEED,ACCELERATION)
		
		# checks whether should rotate the sprite with the inputs or not
		if sprite_lock == false:
			# inputs control the rotation of the sprite
			sprite.rotation.y=lerp_angle(sprite.rotation.y,atan2(direction.x,direction.z)+PI,SPRITE_TURN_SPEED*delta)
		elif sprite_lock == true:
			# velocity control the rotation of the sprite
			sprite.rotation.y=lerp_angle(sprite.rotation.y,atan2(velocity.x,velocity.z)+PI,SPRITE_TURN_SPEED*delta)
	
	# if no buttons are pressed
	else:
		velocity.x = lerp(velocity.x,0.0,ACCELERATION)
		velocity.z = lerp(velocity.z,0.0,ACCELERATION)
	
	move_and_slide()

# once dash cooldown finishes, can dash again
func _on_dash_cooldown_timeout():
	can_dash = true

# clears buffer
func _on_input_buffer_time_timeout():
	wants_to_jump = false
