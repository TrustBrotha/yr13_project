extends GPUParticles3D


# Culls node once particles die
func _on_finished():
	queue_free()
