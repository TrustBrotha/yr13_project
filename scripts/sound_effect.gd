extends AudioStreamPlayer3D

func _ready():
	play()


func play_sound(sound,volume_shift):
	stream=sound
	volume_db=Global.sound_effect_volume+volume_shift



func _on_finished():
	queue_free()