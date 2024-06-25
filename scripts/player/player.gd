extends CharacterBody3D


const SPEED = 10.0
const ACCELERATION = 0.2
const SPRITE_TURN_SPEED = 8
const JUMP_VELOCITY = 10

# defines the state machine to me manipulated as a variable
@onready var state_machine : CharacterStateMachine = $character_state_machine

@onready var cam_pivot_x = $cam_origin_y/cam_origin_x
@onready var cam_pivot_y = $cam_origin_y
@onready var sprite = $Node3D
@onready var dash_timer=$timers/dash_time

@export var sensitivity = 0.5
@export var vel_tolerance = 1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var direction
var sprite_lock = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	
	# controls the rotation of the camera and character controls
	if event is InputEventMouseMotion:
		cam_pivot_y.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		cam_pivot_x.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		cam_pivot_x.rotation.x = clamp(cam_pivot_x.rotation.x,deg_to_rad(-90),deg_to_rad(45))



func _physics_process(delta):

	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()
	
	sprite_lock = state_machine.check_sprite_lock()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_forward", "ui_back")
	direction = (cam_pivot_y.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if state_machine.check_if_can_move():
			velocity.x = lerp(velocity.x,direction.x*SPEED,ACCELERATION)
			velocity.z = lerp(velocity.z,direction.z*SPEED,ACCELERATION)
			
		if sprite_lock == false:
			# controls the rotation of the sprite
			sprite.rotation.y=lerp_angle(sprite.rotation.y,atan2(direction.x,direction.z)+PI,SPRITE_TURN_SPEED*delta)
		elif sprite_lock == true:
			
			sprite.rotation.y=lerp_angle(sprite.rotation.y,atan2(velocity.x,velocity.z)+PI,SPRITE_TURN_SPEED*delta)
		
	else:
		velocity.x = lerp(velocity.x,0.0,ACCELERATION)
		velocity.z = lerp(velocity.z,0.0,ACCELERATION)
	
	move_and_slide()
