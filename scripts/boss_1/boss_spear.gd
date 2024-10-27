extends Node3D

# Assigns all accessed nodes to a var
@onready var all_spear_parts = $boss_spear.get_children()
# Assigns parts of this var to different vars
var spear_blade = []
var spear_guard = []
var spear_pommel = []
var spear_rot = 0.0 # Resets rotation
var spin_speed = 0.05 # Controls how fast each part spins


# Called when the node enters the scene tree for the first time.
func _ready():
	# Splits all of the blade parts into seperate arrays so they can be accessed seperately
	for part in all_spear_parts:
		if part.name.contains("blade"):
			spear_blade.append(part)
		elif part.name.contains("guard"):
			spear_guard.append(part)
		elif part.name.contains("pommel"):
			spear_pommel.append(part)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Progresses the overall rotation of the blade
	spear_rot += spin_speed
	
	# For each part of the blade, rotate each part by the overall spear rotation + a little bit
	# Extra the further along the blade that part is
	var offset = 0.0
	for spear in spear_blade:
		offset += 0.1
		spear.rotation.y = spear_rot + offset
	
	offset = 0.0
	for spear in spear_guard:
		offset += 0.3
		spear.rotation.y =- (spear_rot + offset)
	
	offset = 0.0
	for spear in spear_pommel:
		offset += 0.1
		spear.rotation.y =- (spear_rot+offset)
