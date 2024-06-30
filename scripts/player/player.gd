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
@onready var sprite = $rotated_things
@onready var timers = $timers
@onready var hitbox = $hitbox
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var parry_coll = $rotated_things/parry_hitbox/parry_collision
#@onready var dash_timer = $timers/dash_time
#@onready var dash_cooldown = $timers/dash_cooldown

@export var staggered_state_var : State
var sensitivity = 0.2



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# variables accessed by state machine and player
var direction
var sprite_lock = false
var can_dash = true
var wants_to_jump = false
var health = 1000
var speed = 10.0

var parry_up = false
var block_up = false

var saved_weapon
var parry_forgiveness_active = false
var camera_locked = false
var camera_targets = []
var camera_target

func _ready():
	# gets the mouse actions
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# makes sure the spring arm for the camera doesn't collide with the player
	$cam_origin_y/cam_origin_x/camera_spring.add_excluded_object(self)

func _input(event):
	# controls the rotation of the camera and character controls
	if event is InputEventMouseMotion:
		if camera_locked == false:
			cam_pivot_y.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
			cam_pivot_x.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
			# clamps camera so that you cant move up and around the players head
			cam_pivot_x.rotation.x = clamp(cam_pivot_x.rotation.x,deg_to_rad(-90),
			deg_to_rad(45))
	
	
	if event.is_action_pressed("camera_lock"):
		if camera_locked == false and len(camera_targets)>0:
			camera_locked = true
			camera_target = camera_targets[0]
		elif camera_locked == true:
			camera_locked = false

func lock_cam_target():
	pass
	


func _physics_process(delta):
	
	
	if parry_up == true and saved_weapon != null:
		saved_weapon = null
	
	
	# quits game (as mouse is used cant go to x button)
	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()
	
	# accesses whether should rotate the sprite with the inputs or not
	sprite_lock = state_machine.check_sprite_lock()
	
	if camera_locked == true:
		
		var camera_target_pos = (camera_target.global_position-global_position).normalized()*5
		cam_pivot_y.rotation.y=atan2(camera_target_pos.x,camera_target_pos.z)+PI
		if sprite_lock == false:
			sprite.rotation.y=atan2(camera_target_pos.x,camera_target_pos.z)+PI
	
	# accesses the inputs
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_forward", "ui_back")
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
		
		
		# checks whether should rotate the sprite with the inputs or not
		if sprite_lock == false:
			if camera_locked == false:
				# inputs control the rotation of the sprite
				sprite.rotation.y=lerp_angle(sprite.rotation.y,atan2(direction.x,direction.z)+PI,SPRITE_TURN_SPEED*delta)
	if sprite_lock == true:
		pass
		# velocity control the rotation of the sprite
		# sprite.rotation.y=lerp_angle(sprite.rotation.y,atan2(velocity.x,velocity.z)+PI,SPRITE_TURN_SPEED*delta)
	
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




func start_parry_frames():
	parry_up = true
	parry_coll.disabled = false
	timers.get_node("parry_timer").start()

func _on_parry_timer_timeout():
	parry_up = false
	parry_done.emit()
	parry_coll.disabled = true
	block_up = true

func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy_weapon"):
		saved_weapon = area
		$timers/parry_forgiveness_timer.start()
		parry_forgiveness_active = true



func _on_parry_forgiveness_timer_timeout():
	if saved_weapon != null:
		state_machine.current_state.next_state=staggered_state_var
		var old_health = health
		if parry_up == true:
			pass
		elif block_up == true:
			health-=5
		else:
			health-=10
		
		if old_health != health:
			var enemy_loc = saved_weapon.get_parent().global_position
			velocity=-(enemy_loc-global_position).normalized()*15
		saved_weapon = null








func _on_cam_target_finder_body_entered(body):
	if body != self and body.is_in_group("enemy"):
		camera_targets.append(body)


func _on_cam_target_finder_body_exited(body):
	if body != self:
		camera_targets.erase(body)
