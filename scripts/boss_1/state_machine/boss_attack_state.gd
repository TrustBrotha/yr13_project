extends State

# States which can be moved into
@export var idle_state_var : State
@export var block_state_var : State

# Used nodes in code
@export var animation_tree : AnimationTree
@export var weapon_collision : CollisionShape3D
@export var boss : CharacterBody3D
@export var next_attack_timer : Timer
@onready var attacks=get_children()

var current_attack # Used to call functions from the current attack
var last_start_attack=0 # Makes sure the same attack doesn't play twice in a row
var num_of_start_attacks=3 # Number of attacks which can start a combo currently added
var block_prepared=false # Used to control when the boss can block or not

# Sets the variables needed to be accessed for each attack (could do manually for each)
func _ready():
	for attack in attacks:
		attack.boss=boss
		attack.animation_tree=animation_tree
		attack.weapon_collision=weapon_collision


func state_process(delta):
	# Slows boss down while attacking
	character.velocity.x=lerp(character.velocity.x,0.0,0.3)
	character.velocity.z=lerp(character.velocity.z,0.0,0.3)
	
	# If the boss can block, and the player is withing range and they are attacking,
	# enter block state
	if block_prepared:
		if (character.player_relative_location.length() < character.attack_range and 
		character.player.state_machine.current_state.name=="attack"):
			if Global.player_combo==1:
				next_state=block_state_var
	
	# If not attacking, the boss can block, also check distance to see if player still in range
	# If attacking boss cant block
	if current_attack==null:
		block_prepared=true
		check_distance()
	else:
		block_prepared=false
	
	# Applies gravity
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta


func on_enter():
	# Resets variables, timers, boss velocity
	block_prepared=false
	next_attack_timer.stop()
	character.velocity=Vector3.ZERO
	character.wants_to_chase=true
	# Sets animation tree into attack mode
	character.animation_tree.set("parameters/state/transition_request","attack")
	# Picks a starting combo attack
	choose_start_attack()


func choose_start_attack():
	# Chooses a random number corresponding to an attack which isn't the last attack
	var random_num=randi_range(0,num_of_start_attacks-1)
	while random_num == last_start_attack:
		random_num=randi_range(0,num_of_start_attacks-1)
	# Starts chosen attack and sets it to the last attack so the next time cant pick it again
	current_attack=attacks[random_num]
	last_start_attack=random_num
	attack()


# Calls the function which controls the attack from the current attack
# Called from this script as well as from the current attack for folluw up attacks 
func attack():
	current_attack.control_attack()


# Called when not doing follow up attack
func attack_finished():
	current_attack=null
	next_attack_timer.wait_time=0.5*Global.boss_speed
	next_attack_timer.start()


# After a delay, chooses next starting combo attack if the player is still in range
func _on_next_attack_timer_timeout():
	if character.player_relative_location.length() < character.attack_range:
		choose_start_attack()


# Checks if player is still in range, if not, change to idle state
func check_distance():
	if character.player_relative_location.length() > character.attack_range:
		next_state=idle_state_var


# Stops timer. If not here multiple attacks can run at the same time.
func on_exit():
	next_attack_timer.stop()


