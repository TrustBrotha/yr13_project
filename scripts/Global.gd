extends Node

var music_volume = -15
var sound_effect_volume = 0
var font_size = 17




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	music_volume = clamp(music_volume,-80,0)
	sound_effect_volume = clamp(sound_effect_volume,-80,15)
	font_size = clamp(font_size,7,27)
