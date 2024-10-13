extends CanvasLayer
@onready var screens=$screens.get_children()
@export var current_screen:Node2D

@export var music_label:Label
@export var sfx_label:Label
@export var screen_type_text:Button
@export var border_type_text:Button
@export var resolution_type_text:Button
@export var fog_type_text:Button
@export var sdfgi_type_text:Button

var screen_switch_time=0.3


var window_modes=["WINDOWED","FULLSCREEN",]
var highlighted_window_mode=0
var saved_window_mode=0

var border_modes=["DISABLED","ENABLED",]
var highlighted_border_mode=0
var saved_border_mode=0

var fog_modes=["ENABLED","DISABLED",]
var highlighted_fog_mode=0
var saved_fog_mode=0

var sdfgi_modes=["ENABLED","DISABLED",]
var highlighted_sdfgi_mode=0
var saved_sdfgi_mode=0

var resolution_modes=["1920 x 1080","2560 x 1440","3840 x 2160",]
var screen_sizes=[Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]
var highlighted_resolution_mode=0
var saved_resolution_mode=0


# Called when the node enters the scene tree for the first time.
func _ready():
	change_screen(screens[0])
	update_audio_labels()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass









func move_screen(dir,screen):
	var locations=[-1000.0,0.0]
	var loc=locations[dir]
	var t=get_tree().create_tween()
	t.tween_property(screen,"position",Vector2(loc,0.0),screen_switch_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func change_screen(wanted_screen):
	move_screen(0,current_screen)
	if wanted_screen!=null:
		await get_tree().create_timer(screen_switch_time).timeout
		current_screen=wanted_screen
		move_screen(1,current_screen)



func _on_play_pressed():
	change_screen(null)
	get_parent().switch_scenes_animation()

func _on_settings_pressed():
	change_screen(screens[1])

func _on_credits_pressed():
	pass

func _on_quit_pressed():
	get_tree().quit()



func _on_audio_pressed():
	change_screen(screens[2])

func _on_visual_pressed():
	change_screen(screens[3])

func _on_key_binds_pressed():
	change_screen(screens[4])

func _on_settings_back_pressed():
	change_screen(screens[0])



func _on_music_down_pressed():
	Global.music_volume-=3
	update_audio_labels()

func _on_music_up_pressed():
	Global.music_volume+=3
	update_audio_labels()

func _on_sfx_down_pressed():
	Global.sound_effect_volume-=3
	update_audio_labels()

func _on_sfx_up_pressed():
	Global.sound_effect_volume+=3
	update_audio_labels()

func update_audio_labels():
	Global.music_volume = clamp(Global.music_volume,-80,0)
	Global.sound_effect_volume = clamp(Global.sound_effect_volume,-80,0)
	music_label.text=str(Global.music_volume+80)
	sfx_label.text=str(Global.sound_effect_volume+80)

func _on_audio_settings_back_pressed():
	change_screen(screens[1])



func _on_change_display_type_pressed():
	highlighted_window_mode+=1
	highlighted_window_mode%=2
	screen_type_text.text=window_modes[highlighted_window_mode]

func _on_apply_display_type_pressed():
	saved_window_mode=highlighted_window_mode
	if highlighted_window_mode==0: #windowed
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif highlighted_window_mode==1: #fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_change_border_mode_pressed():
	highlighted_border_mode+=1
	highlighted_border_mode%=2
	border_type_text.text=border_modes[highlighted_border_mode]

func _on_apply_border_mode_pressed():
	saved_border_mode=highlighted_border_mode
	if highlighted_border_mode==0:#disabled
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
	elif highlighted_border_mode==1:#enabled
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)

func _on_resolution_mode_pressed():
	highlighted_resolution_mode+=1
	highlighted_resolution_mode%=3
	resolution_type_text.text=resolution_modes[highlighted_resolution_mode]

func _on_apply_resolution_pressed():
	saved_resolution_mode=highlighted_resolution_mode
	DisplayServer.window_set_size(screen_sizes[highlighted_resolution_mode])

func _on_change_fog_mode_pressed():
	highlighted_fog_mode+=1
	highlighted_fog_mode%=2
	fog_type_text.text=fog_modes[highlighted_fog_mode]

func _on_apply_fog_pressed():
	saved_fog_mode=highlighted_fog_mode
	if highlighted_fog_mode==0: #enabled
		Global.fog=true
	elif highlighted_fog_mode==1: #enabled
		Global.fog=false
	get_parent().change_visuals()

func _on_change_sdfgi_mode_pressed():
	highlighted_sdfgi_mode+=1
	highlighted_sdfgi_mode%=2
	sdfgi_type_text.text=sdfgi_modes[highlighted_sdfgi_mode]


func _on_apply_sdfgi_pressed():
	saved_sdfgi_mode=highlighted_sdfgi_mode
	if highlighted_sdfgi_mode==0: #enabled
		Global.sdfgi=true
	elif highlighted_sdfgi_mode==1: #enabled
		Global.sdfgi=false
	get_parent().change_visuals()
	




func _on_visual_settings_back_pressed():
	
	screen_type_text.text=window_modes[saved_window_mode]
	highlighted_window_mode=saved_window_mode
	
	border_type_text.text=border_modes[saved_border_mode]
	highlighted_border_mode=saved_border_mode
	
	resolution_type_text.text=resolution_modes[saved_resolution_mode]
	highlighted_resolution_mode=saved_resolution_mode
	
	change_screen(screens[1])





func _on_key_binds_back_pressed():
	change_screen(screens[1])






