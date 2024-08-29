extends Node3D
@onready var hud=$HUD
@onready var player=$player
@export var beam_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("enter"):
		var laser = beam_scene.instantiate()
		$Node3D.add_child(laser)
	hud.state_label.text=str(player.state_machine.current_state.name)
	hud.health_label.text=str(player.health)
