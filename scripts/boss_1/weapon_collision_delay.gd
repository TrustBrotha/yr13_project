extends Area3D

# Used to save data from previous frames
var loc_data = []
var rot_data = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Places the Current location and rotation of the boss weapon at the end of the array
	loc_data.append(get_parent().global_position)
	rot_data.append(get_parent().global_rotation)
	
	# Controls the length of the array based on the framerate (delta, 1/fps),
	# And a set amount of time in seconds (boss_attack_delay)
	while len(loc_data) > floor(Global.boss_attack_delay / delta):
		loc_data.remove_at(0)
	while len(rot_data) > floor(Global.boss_attack_delay / delta):
		rot_data.remove_at(0)
	
	# This results in the First item in the list being the position and rotation of the weapon
	# Boss_attack_delay seconds ago
	if len(loc_data) > 0 and len(rot_data) > 0:
		global_position = loc_data[0]
		global_rotation = rot_data[0]
