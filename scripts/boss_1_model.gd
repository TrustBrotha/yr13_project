extends Node3D
@onready var cloak_bones = [
	"cloak_outer_2.L","cloak_outer_3.L","cloak_outer_4.L","cloak_outer_5.L","cloak_outer_6.L","cloak_outer_7.L",
	"cloak_outer_2.R","cloak_outer_3.R","cloak_outer_4.R","cloak_outer_5.R","cloak_outer_6.R","cloak_outer_7.R",
	"cloak_inner_2.L","cloak_inner_3.L","cloak_inner_4.L","cloak_inner_5.L","cloak_inner_6.L","cloak_inner_7.L",
	"cloak_inner_2.L","cloak_inner_3.R","cloak_inner_4.R","cloak_inner_5.R","cloak_inner_6.R","cloak_inner_7.R",
	"cloak_front_1","cloak_front_2","cloak_front_3","cloak_back_1","cloak_back_2"]
@export var cloak_bone_scene : PackedScene



# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(cloak_bones)):
		var cloak_bone=cloak_bone_scene.instantiate()
		cloak_bone.bone_name=cloak_bones[i]
		cloak_bone.forward_axis=1
		$Armature/Skeleton3D.add_child(cloak_bone)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



