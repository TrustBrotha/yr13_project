extends Node


# Loaded music files
var menu_music
var boss_1_music=load("res://sfx/music/Unsinkable [ ezmp3.cc ].mp3")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Placeholder, different music would have different functions
	$music_player.volume_db = Global.music_volume
	$music_player.stream = boss_1_music
	$music_player.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Updates the volume of the music
	$music_player.volume_db=Global.music_volume
