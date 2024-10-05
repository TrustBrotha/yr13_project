extends State


func state_process(delta):
	character.velocity=lerp(character.velocity,Vector3.ZERO,0.3)
