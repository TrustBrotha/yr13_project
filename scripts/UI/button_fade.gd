extends Sprite2D

var scaley # Saved scale.y
var length = 1.5 # Controls how far the effect moves horizontally


# Called when the node enters the scene tree for the first time.
func _ready():
	# Saves original scale.y
	scaley = scale.y


# When hovered over, the effect moves across button
func _on_play_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(length, scaley), 0.1
	).set_trans(Tween.TRANS_LINEAR)


# When stopped hovering, the effect fades across the button
func _on_play_mouse_exited():
	if is_inside_tree():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(0.0, scaley), 0.1
		).set_trans(Tween.TRANS_LINEAR)


# When the button is pushed, makes the effect grow more while fading away, then reset when done
func _on_play_pressed():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "scale", Vector2(length * 2, scaley), 0.1
	).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2
	).set_trans(Tween.TRANS_LINEAR)
	
	tween.set_parallel(false)
	tween.tween_callback(reset_visuals)


func reset_visuals():
	scale.x = 0.0
	modulate = Color(1, 1, 1, 1)
