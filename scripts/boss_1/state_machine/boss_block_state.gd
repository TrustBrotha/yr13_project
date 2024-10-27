extends State

# States to move into
@export var attack_state_var : State
@export var idle_state_var : State
@export var dodge_back_state_var : State

var decision = randi_range(0, 2) # Stores the decision to dodge or continue blocking
var attack_called_once_fix = false # Since there should be a delay before starting an attack after
# Finished blocking, this should be called once, however check is in delta, so this var fixes this


func state_process(delta):
	# Slows boss down
	character.velocity.x = lerp(character.velocity.x, 0.0, 0.3)
	character.velocity.z = lerp(character.velocity.z, 0.0, 0.3)
	
	# If the player isn't attacking, either start attacking if in range, or return to idle
	if character.player.state_machine.current_state.name != "attack":
		if character.player_relative_location.length() < character.attack_range:
			attack(0.25)
		else:
			next_state = idle_state_var
	# If the player is attacking, either dodge or condinue blocking
	# Else can be replace with other options
	else:
		if character.player.state_machine.current_state.combo == 2:
			if decision == 0:
				next_state = dodge_back_state_var
			else:
				pass
		
		elif character.player.state_machine.current_state.combo == 3:
			if decision == 0:
				pass
				
			else:
				attack(0.35)
	
	# Apply gravity
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta


func attack(wait_time):
	# Only run once, swiches to attack state after short delay
	if not attack_called_once_fix:
		attack_called_once_fix = true
		await get_tree().create_timer(wait_time).timeout
		next_state = attack_state_var


func on_enter():
	# Resets vars
	attack_called_once_fix = false
	# Starts blocking, takes half damage
	character.blocking = true
	# Makes decision
	decision = randi_range(0, 2)
	# Switchs to block animation state
	character.animation_tree.set("parameters/state/transition_request", "block")


func on_exit():
	# Stops blocking, meaning takes full damage
	character.blocking = false
