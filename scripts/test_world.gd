extends Node3D

var menu_open=false # Controls whether the menu is open or closed

# Assigns nodes / scenes to variables to be used in the script
@onready var hud=$HUD
@onready var player=$player
@export var beam_scene : PackedScene
@onready var beam_spawns1=$beam_spawns1.get_children()
@onready var beam_spawns2=$beam_spawns2.get_children()
@export var menu : CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player_health=Global.player_max_health
	Global.boss_health=Global.boss_max_health
	change_visuals()


# Controls opening and closing the menu
func _input(event):
	if event.is_action_pressed("ui_quit"):
		if menu_open==false:
			menu_open=true
			menu.change_screen(menu.screens[0])
		elif menu_open==true:
			menu_open=false
			menu.change_screen(null)


# Resets scene when push play again
func switch_scenes_animation():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


# Controls the positioning and timing for spawning the beams, called from the boss script
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


# Updates visuals when changed in settings
func change_visuals():
	$WorldEnvironment.environment.volumetric_fog_enabled=Global.fog
	$WorldEnvironment.environment.sdfgi_enabled=Global.sdfgi
