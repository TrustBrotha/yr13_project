extends AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready():
	# makes the animations play at different speeds
	set("parameters/TimeScale 4/scale", float(1.0 / Global.boss_speed))
	set("parameters/TimeScale 5/scale", float(1.0 / Global.boss_speed))
	set("parameters/TimeScale 6/scale", float(1.0 / Global.boss_speed))
	set("parameters/TimeScale 7/scale", float(1.0 / Global.boss_speed))
	set("parameters/TimeScale 8/scale", float(1.0 / Global.boss_speed))
	set("parameters/TimeScale 9/scale", float(1.0 / Global.boss_speed))
	set("parameters/TimeScale 10/scale", float(1.0 / Global.boss_speed))
