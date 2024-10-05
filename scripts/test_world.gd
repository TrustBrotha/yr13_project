extends Node3D
@onready var hud=$HUD
@onready var player=$player

@export var beam_scene : PackedScene
@onready var beam_spawns=$beam_spawns.get_children()
var beam_rotations=[0,0,]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hud.state_label.text=str(player.state_machine.current_state.name)
	hud.health_label.text=str(player.health)


func spawn_beams():
	for spawn in beam_spawns:
		var beam=beam_scene.instantiate()
		spawn.add_child(beam)
