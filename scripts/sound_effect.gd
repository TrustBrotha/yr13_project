extends AudioStreamPlayer3D


func _ready():
	play()


# Sets the sound which wants to be played and the adjustment to that particular sound.
# Eg if one sound file is louder, can have a - volume shift to account for that
func play_sound(sound,volume_shift):
	stream=sound
	volume_db=Global.sound_effect_volume+volume_shift


# Deletes once finished for performance
func _on_finished():
	queue_free()
