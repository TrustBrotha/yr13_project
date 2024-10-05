extends Node3D
@onready var spines = $resonance_beam_main.get_children()
@onready var beam_sound_1 = preload("res://sfx/boss_1/beam/beam_1.wav")
@onready var beam_sound_2 = preload("res://sfx/boss_1/beam/beam_2.wav")
var count = 0
var speed = 3
var end = false
var following = true
var rot=0.0
var start_beam=false
var spin_speed=0.1
var time_elapsed=0.0
var played_sound=false
var offset=0
# Called when the node enters the scene tree for the first time.
func _ready():
	var beam_sounds=[beam_sound_1,beam_sound_2]
	var beam_sound=beam_sounds[randi_range(0,1)]
	$beam_sound.stream=beam_sound
	spines.reverse()
	for spine in spines:
		spine.visible = false
	
	$beam_start.play()
	$start.emitting=true
	$inner_beam.emitting=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if start_beam==true:
		if count<121:
			for i in range(speed):
				if count<121:
					spines[count].visible=true
					count+=1
		
		animation(delta)
		
		if played_sound == false:
			$beam_sound.play()
			played_sound=true
	
	if end == true:
		$mid_beam.process_material.color.a=lerp($mid_beam.process_material.color.a,0.0,0.1)
		$inner_beam.process_material.color.a=lerp($inner_beam.process_material.color.a,0.0,0.1)
		$outer_beam.process_material.color.a=lerp($outer_beam.process_material.color.a,0.0,0.1)
		$start.process_material.color.a=lerp($start.process_material.color.a,0.0,0.1)
		$small_dots.emitting=false
		$sparks.emitting=false
		$resonance_beam_main.scale.x=lerp($resonance_beam_main.scale.x,0.0,0.1)
		$resonance_beam_main.scale.y=lerp($resonance_beam_main.scale.y,0.0,0.1)

func animation(delta):
	time_elapsed+=1.0*delta
	
	spin_speed=0.8*(cos(time_elapsed))
	rot+=spin_speed
	var spine_offset=0.0
	for spine in spines:
		spine.rotation.z=rot+spine_offset
		spine_offset+=0.4*spin_speed




func _on_end_timeout():
	end=true


func _on_delete_timeout():
	queue_free()


func _on_start_main_beam_timeout():
	following = false
	top_level=true
	$small_dots.emitting=true
	$sparks.emitting=true
	start_beam=true
	$mid_beam.emitting=true
	$outer_beam.emitting=true
