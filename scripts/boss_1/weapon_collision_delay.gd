extends Area3D
var loc_data=[]
var rot_data=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#loc_data.append(len(loc_data))
	loc_data.append(get_parent().global_position)
	rot_data.append(get_parent().global_rotation)
	
	while len(loc_data)>floor(Global.boss_attack_delay/delta):
		loc_data.remove_at(0)
	while len(rot_data)>floor(Global.boss_attack_delay/delta):
		rot_data.remove_at(0)
	
	global_position=loc_data[0]
	global_rotation=rot_data[len(rot_data)-1]
