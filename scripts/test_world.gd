extends Node3D

@export var menu_scene : PackedScene
var menu_open=false
@onready var hud=$HUD
@onready var player=$player

@export var beam_scene : PackedScene
@onready var beam_spawns=$beam_spawns.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	change_visuals()

func _input(event):
	if event.is_action_pressed("ui_quit"):
		if menu_open==false:
			menu_open=true
			var menu=menu_scene.instantiate()
			menu.name="ingame_menu"
			add_child(menu)
		elif menu_open==true:
			get_node("ingame_menu").change_screen(null)
			await get_tree().create_timer(0.5).timeout
			get_node("ingame_menu").queue_free()
			menu_open=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func switch_scenes_animation():
	Global.player_health=1000
	Global.boss_health=1000
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func spawn_beams():
	for spawn in beam_spawns:
		var beam=beam_scene.instantiate()
		spawn.add_child(beam)

func change_visuals():
	$WorldEnvironment.environment.volumetric_fog_enabled=Global.fog
	$WorldEnvironment.environment.sdfgi_enabled=Global.sdfgi
