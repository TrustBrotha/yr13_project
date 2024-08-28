extends Node3D
@onready var spines = $"resonance_beam - Copy/Armature/Skeleton3D".get_children()

var count = 48
var first_time=true
var finished_startup=true
var speed = 3
var end = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for spine in spines:
		spine.visible = false
	$start.emitting=true
	$inner_beam.emitting=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if finished_startup==false:
		for i in range(speed):
			print(count)
			spines[count].visible=true
			count-=1
			if count<0:
				if first_time == true:
					count=99
					first_time=false
				else:
					finished_startup = true
	
	if end == true:
		$mid_beam.process_material.color.a=lerp($mid_beam.process_material.color.a,0.0,0.1)
		$inner_beam.process_material.color.a=lerp($inner_beam.process_material.color.a,0.0,0.1)
		$outer_beam.process_material.color.a=lerp($outer_beam.process_material.color.a,0.0,0.1)
		$start.process_material.color.a=lerp($start.process_material.color.a,0.0,0.1)
		$small_dots.emitting=false
		$"resonance_beam - Copy".scale.x=lerp($"resonance_beam - Copy".scale.x,0.0,0.1)
		$"resonance_beam - Copy".scale.y=lerp($"resonance_beam - Copy".scale.y,0.0,0.1)

func _on_end_timeout():
	end=true


func _on_delete_timeout():
	for spine in spines:
		spine.visible = false


func _on_start_main_beam_timeout():
	$small_dots.emitting=true
	$"resonance_beam - Copy/AnimationPlayer".play("ArmatureAction")
	$mid_beam.emitting=true
	$outer_beam.emitting=true
	finished_startup=false
