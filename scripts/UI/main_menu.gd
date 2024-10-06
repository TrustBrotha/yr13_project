extends Node3D
#(-0, 3.356783, -4.330125)
#(0, 0, 0)
#(-0.523599, 0, 0)
#(0, -3.141593, 0)

#button orange #ff8900


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func switch_scenes_animation():
	var animation_time=2
	var rot_delay=1
	switch_scenes(animation_time)
	
	var cam_pos=Vector3(-0, 3.356783, -4.330125)
	var p=get_tree().create_tween()
	p.tween_property($Camera3D,"global_position",cam_pos,animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(rot_delay).timeout
	var cam_rot=Vector3(-30*PI/180,PI,0)
	var r=get_tree().create_tween()
	r.tween_property($Camera3D,"rotation",cam_rot,animation_time-rot_delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func switch_scenes(switch_scene_delay):
	await get_tree().create_timer(switch_scene_delay+0.1).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")


