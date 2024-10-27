extends Node

## Saves some variables which are accessed by many files


# Sound settings
var music_volume = -30
var sound_effect_volume = -15

# Saved player data
var player_max_health = 200
var boss_max_health = 750
var player_health = 200
var boss_health = 750


# Data to control the boss difficulty / tweaking
var boss_speed = 1.4 # 1.4
var boss_attack_delay = 0.05
# Data accessed by boss from player and vice versa
var boss_current_attack_damage = 10
var player_attack_damage = 30
var player_combo = 1

# Used visual settings
var sdfgi = true
var fog = true
var cloth = true
# Saved visual settings
var saved_window_mode = 0
var saved_border_mode = 0
var saved_fog_mode = 0
var saved_sdfgi_mode = 0
var saved_cloth_mode = 0
var saved_resolution_mode = 0

# Creates config file
var config = ConfigFile.new()


# Gets the saved settings when the game is opened
func _ready():
	read()

func _input(event):
	if event.is_action_pressed("boss_speed_down"):
		boss_speed+=0.05
		print(1.0/boss_speed)
	if event.is_action_pressed("boss_speed_up"):
		boss_speed-=0.05
		print(1.0/boss_speed)

# Called when game is closed and saves the audio and visual settings to the file
func save():
	config.set_value("sound_settings", "music_volume", music_volume)
	config.set_value("sound_settings", "sfx_volume", sound_effect_volume)
	
	config.set_value("visual_settings", "saved_window_mode", saved_window_mode)
	config.set_value("visual_settings", "saved_border_mode", saved_border_mode)
	config.set_value("visual_settings", "saved_fog_mode", saved_fog_mode)
	config.set_value("visual_settings", "saved_sdfgi_mode", saved_sdfgi_mode)
	config.set_value("visual_settings", "saved_cloth_mode", saved_cloth_mode)
	config.set_value("visual_settings", "saved_resolution_mode", saved_resolution_mode)
	
	config.save("res://savesettings.cfg")


# reads the saved settings and assigns them to their corresponding variables in this file
func read():
	var err = config.load("res://savesettings.cfg")
	if err == OK:
		music_volume = config.get_value("sound_settings", "music_volume")
		sound_effect_volume = config.get_value("sound_settings", "sfx_volume")
		
		saved_window_mode = config.get_value("visual_settings", "saved_window_mode")
		saved_border_mode = config.get_value("visual_settings", "saved_border_mode")
		saved_fog_mode = config.get_value("visual_settings", "saved_fog_mode")
		saved_sdfgi_mode = config.get_value("visual_settings", "saved_sdfgi_mode")
		saved_cloth_mode = config.get_value("visual_settings", "saved_cloth_mode")
		saved_resolution_mode = config.get_value("visual_settings", "saved_resolution_mode")
