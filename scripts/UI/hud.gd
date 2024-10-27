extends CanvasLayer


func _ready():
	$Control/player_health.max_value = Global.player_max_health
	$Control2/boss_health.max_value = Global.boss_max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Updates the health bars and FPS counter
func _process(delta):
	$fps_label.text = str(Engine.get_frames_per_second())
	$Control/player_health.value = Global.player_health
	$Control2/boss_health.value = Global.boss_health
