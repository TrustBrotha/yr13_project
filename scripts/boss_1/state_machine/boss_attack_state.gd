extends State



@export var idle_state_var : State


@export var animation_tree : AnimationTree
@export var weapon_collision : CollisionShape3D
@onready var attacks=get_children()



var current_attack
var next_attack
var last_start_attack=0
var num_of_start_attacks=3
func _ready():
	for attack in attacks:
		attack.boss=character
		attack.animation_tree=animation_tree
		attack.weapon_collision=weapon_collision



func state_process(delta):
	character.velocity=Vector3.ZERO
	
	
	
	
	if next_attack!=null:
		current_attack=next_attack
		attack()
		next_attack=null
		
	if current_attack==null:
		check_distance()






func on_enter():
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
	await get_tree().create_timer(1).timeout
	#next_state=idle_state_var
	current_attack=null
	if character.player_relative_location.length() < character.attack_range:
		choose_start_attack()
	


func check_distance():
	if character.player_relative_location.length() > character.attack_range:
		next_state=idle_state_var



func on_exit():
	pass

func state_input(event : InputEvent):
	pass




