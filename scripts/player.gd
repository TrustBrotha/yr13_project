extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var cam_pivot_x = $cam_origin_y/cam_origin_x
@onready var cam_pivot_y = $cam_origin_y

@export var sensitivity = 0.5
@export var vel_tolerance = 2
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		
		cam_pivot_y.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		cam_pivot_x.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		cam_pivot_x.rotation.x = clamp(cam_pivot_x.rotation.x,deg_to_rad(-90),deg_to_rad(45))



func _physics_process(delta):
	
	var vel_size = sqrt(velocity.x**2+velocity.y**2+velocity.z**2)
	print(vel_size)
	if vel_size > vel_tolerance:
		$Node3D.rotation.y=lerp_angle($Node3D.rotation.y,atan2(velocity.x,velocity.z),7.5*delta)
	if velocity == Vector3.ZERO:
		$Node3D.rotation.y=$Node3D.rotation.y
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (cam_pivot_y.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	
	
	move_and_slide()
