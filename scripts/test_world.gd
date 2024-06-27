extends Node3D
@onready var hud=$HUD
@onready var player=$CharacterBody3D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hud.state_label.text=str(player.state_machine.current_state.name)
