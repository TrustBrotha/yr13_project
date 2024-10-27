extends Node

## Saves some variables which are accessed by many files

# Sound settings
var music_volume = -30
var sound_effect_volume = -15

# Saved player data
var player_max_health=200
var boss_max_health=1000
var player_health=100
var boss_health=1000


# Data to control the boss difficulty / tweaking
var boss_speed=1.4 # 1.4
var boss_attack_delay=0.05
# Data accessed by boss from player and vice versa
var boss_current_attack_damage=10
var player_attack_damage=30
var player_combo=1

# Saved visual settings
var sdfgi=true
var fog=true
var cloth=true
var saved_window_mode=0
var saved_border_mode=0
var saved_fog_mode=0
var saved_sdfgi_mode=0
var saved_cloth_mode=0
var saved_resolution_mode=0
