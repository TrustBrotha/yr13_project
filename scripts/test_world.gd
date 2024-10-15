extends Node3D


var menu_open=false
@onready var hud=$HUD
@onready var player=$player

@export var beam_scene : PackedScene
@onready var beam_spawns1=$beam_spawns1.get_children()
@onready var beam_spawns2=$beam_spawns2.get_children()

@export var menu : CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	
	change_visuals()

func _input(event):
	if event.is_action_pressed("ui_quit"):
		if menu_open==false:
			menu_open=true
			menu.change_screen(menu.screens[0])
		elif menu_open==true:
			menu_open=false
			menu.change_screen(null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func switch_scenes_animation():
	Global.player_health=100
	Global.boss_health=1000
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func spawn_beams(mode):
	player.force_remove_cam_lock()
	if mode==1:
		for spawn in beam_spawns1:
			var beam=beam_scene.instantiate()
			spawn.add_child(beam)
	elif mode==2:
		for spawn in beam_spawns1:
			var beam=beam_scene.instantiate()
			spawn.add_child(beam)
		await get_tree().create_timer(2).timeout
		for spawn in beam_spawns2:
			var beam=beam_scene.instantiate()
			spawn.add_child(beam)

func change_visuals():
	$WorldEnvironment.environment.volumetric_fog_enabled=Global.fog
	$WorldEnvironment.environment.sdfgi_enabled=Global.sdfgi
