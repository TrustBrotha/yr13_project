extends Sprite2D
var scaley
var length=1.5
#scalex = 0,0.25
# Called when the node enters the scene tree for the first time.
func _ready():
	scaley=scale.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_mouse_entered():
	var t=get_tree().create_tween()
	t.tween_property(self,"scale",Vector2(length,scaley),0.1).set_trans(Tween.TRANS_LINEAR)


func _on_play_mouse_exited():
	if is_inside_tree():
		var t=get_tree().create_tween()
		t.tween_property(self,"scale",Vector2(0.0,scaley),0.1).set_trans(Tween.TRANS_LINEAR)


func _on_play_pressed():
	var t=get_tree().create_tween()
	t.set_parallel(true)
	t.tween_property(self,"scale",Vector2(length*2,scaley),0.1).set_trans(Tween.TRANS_LINEAR)
	t.tween_property(self,"modulate",Color(1,1,1,0),0.2).set_trans(Tween.TRANS_LINEAR)
	t.set_parallel(false)
	t.tween_callback(reset_visuals)

func reset_visuals():
	scale.x=0.0
	modulate=Color(1,1,1,1)
