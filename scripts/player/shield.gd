extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready():
	emitting=true

# Deletes once done for performance
func _on_finished():
	queue_free()


# Deletes if there is a successful parry
func parry():
	queue_free()
