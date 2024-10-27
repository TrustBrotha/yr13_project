extends Node3D

# Makes it easier to acces UI scene through code
@export var ui : CanvasLayer

# Saved data
# (-0, 3.356783, -4.330125)
# (0, 0, 0)
# (-0.523599, 0, 0)
# (0, -3.141593, 0)
# Button orange: #ff8900


# Called when the node enters the scene tree for the first time.
func _ready():
	# Sets animations to play while in title screen
	$boss_1/AnimationPlayer.play("walk_forward")
	$Sekiro_like_player_character/AnimationPlayer.play("idle_basic")
	# Opens the home page in the UI
	ui.change_screen(ui.screens[0])


# Controls the movement of the camera when pressing play
func switch_scenes_animation():
	var animation_time = 2
	var rot_delay = 1
	# Controls when to switch scene
	switch_scenes(animation_time)
	
	# Tweens the camera to fly and rotate towards the player camera
	var cam_pos = Vector3(-0, 2.606783, -3.031087)
	var tween = get_tree().create_tween()
	tween.tween_property($Camera3D, "global_position", cam_pos, animation_time
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(rot_delay).timeout
	var cam_rot = Vector3(-30 * PI / 180, PI, 0)
	var tween2 = get_tree().create_tween()
	tween2.tween_property($Camera3D, "rotation", cam_rot, animation_time - rot_delay
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


# Controls when to switch scene
func switch_scenes(switch_scene_delay):
	await get_tree().create_timer(switch_scene_delay + 0.1).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")


# Called from UI to update fog and sdfgi settings
func change_visuals():
	$WorldEnvironment.environment.volumetric_fog_enabled = Global.fog
	$WorldEnvironment.environment.sdfgi_enabled = Global.sdfgi
