extends Node3D

# Assigns all parts of the beam to a variable
@onready var spines = $resonance_beam_main.get_children()
# Loads sounds into variables
@onready var beam_sound_1 = preload("res://sfx/boss_1/beam/beam_1.wav")
@onready var beam_sound_2 = preload("res://sfx/boss_1/beam/beam_2.wav")
var count = 0 # Used to track which part of the beam is being affected
var speed = 3 # Used to control how fast the beam moves
var end = false # Used to control when the beam should start ending
var rot = 0.0 # Used to control rotation of the beam
var start_beam = false # Used to control when the beam parts are seen / animated
var spin_speed = 0.1 # Used to control how fast the beam spins
var time_elapsed = 0.0 # Used to calculate rot
var played_sound = false # Makes sure the sound is only played once
var offset = 0 # Used to make each part of the beam off centered to the previous


# Called when the node enters the scene tree for the first time.
func _ready():
	# Picks a sound to be played
	var beam_sounds = [beam_sound_1, beam_sound_2]
	var beam_sound = beam_sounds[randi_range(0, 1)]
	$beam_sound.stream = beam_sound
	
	# Resets the parts of the beam
	spines.reverse()
	for spine in spines:
		spine.visible = false
	
	# Starts timer which calls the next step for the beam
	$beam_start.play()
	
	# Starts the first parts of the beam effects
	$start.emitting = true
	$inner_beam.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If the beam has started
	if start_beam:
		# Controls which parts of the beam is visible
		if count < 121:
			for i in range(speed):
				if count < 121:
					spines[count].visible = true
					count += 1
		
		# Controls the spinning of each part
		animation(delta)
		
		# Plays the sound once
		if not played_sound:
			$beam_sound.play()
			played_sound = true
	
	# If the ending sequence has started, Fade effects away
	if end:
		$mid_beam.process_material.color.a = lerp($mid_beam.process_material.color.a, 0.0, 0.1)
		$inner_beam.process_material.color.a = lerp($inner_beam.process_material.color.a, 0.0, 0.1)
		$outer_beam.process_material.color.a = lerp($outer_beam.process_material.color.a, 0.0, 0.1)
		$start.process_material.color.a = lerp($start.process_material.color.a, 0.0, 0.1)
		$small_dots.emitting = false
		$sparks.emitting = false
		$resonance_beam_main.scale.x = lerp($resonance_beam_main.scale.x, 0.0, 0.1)
		$resonance_beam_main.scale.y = lerp($resonance_beam_main.scale.y, 0.0, 0.1)


# Controls the animation for spinning parts of the beam
func animation(delta):
	time_elapsed += 1.0 * delta
	
	spin_speed = 0.8 * (cos(time_elapsed))
	rot += spin_speed
	var spine_offset = 0.0
	for spine in spines:
		spine.rotation.z = rot + spine_offset
		spine_offset += 0.4 * spin_speed


# Starts the ending sequence 
func _on_end_timeout():
	end = true


# Deletes scene to avoid performance issues
func _on_delete_timeout():
	queue_free()


func _on_start_main_beam_timeout():
	# Sets the beam damage 
	Global.boss_current_attack_damage = 60
	# Starts the timer to turn off collision
	collision_off()
	# Starts effects
	$small_dots.emitting = true
	$sparks.emitting = true
	start_beam = true
	$mid_beam.emitting = true
	$outer_beam.emitting = true
	
	# Controls collision shape
	var tween = get_tree().create_tween()
	tween.tween_property($Area3D/CollisionShape3D, "position", Vector3(0, 0, -30), 0.6
	).set_trans(Tween.TRANS_LINEAR)


# Turns off collision after a set amount of time
func collision_off():
	await get_tree().create_timer(1.7).timeout
	$Area3D/CollisionShape3D.disabled = true

