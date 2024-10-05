extends State



@export var idle_state_var : State
@export var block_state_var : State

@export var animation_tree : AnimationTree
@export var weapon_collision : CollisionShape3D
@export var boss : CharacterBody3D
@export var next_attack_timer : Timer
@onready var attacks=get_children()



var current_attack

var last_start_attack=0
var num_of_start_attacks=3

var block_prepared


func _ready():
	for attack in attacks:
		attack.boss=boss
		attack.animation_tree=animation_tree
		attack.weapon_collision=weapon_collision



func state_process(delta):
	
	character.velocity=Vector3.ZERO
	
	
	if block_prepared==true:
		if character.player_relative_location.length() < character.attack_range and character.player.state_machine.current_state.name=="attack":
			next_state=block_state_var
	
	
	
	
	if current_attack==null:
		block_prepared=true
		check_distance()
	else:
		block_prepared=false
	
	
	
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta






func on_enter():
	character.wants_to_chase=true
	character.animation_tree.set("parameters/state/transition_request","attack")
	choose_start_attack()

func choose_start_attack():
	var r=randi_range(0,num_of_start_attacks-1)
	while r == last_start_attack:
		r=randi_range(0,num_of_start_attacks-1)
	current_attack=attacks[r]
	last_start_attack=r
	attack()


func attack():
	current_attack.control_attack()




func attack_finished():
	current_attack=null
	next_attack_timer.wait_time=0.3
	next_attack_timer.start()


func check_distance():
	if character.player_relative_location.length() > character.attack_range:
		next_state=idle_state_var



func on_exit():
	next_attack_timer.stop()

func state_input(event : InputEvent):
	pass






func _on_next_attack_timer_timeout():
	if character.player_relative_location.length() < character.attack_range:
		choose_start_attack()
