extends CanvasLayer
@onready var screens=$screens.get_children()
@export var current_screen:Node2D
var screen_switch_time=0.3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func move_screen(dir,screen):
	var locations=[-800.0,0.0]
	var loc=locations[dir]
	var t=get_tree().create_tween()
	t.tween_property(screen,"position",Vector2(loc,0.0),screen_switch_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func change_screen(wanted_screen):
	move_screen(0,current_screen)
	await get_tree().create_timer(screen_switch_time+0.1).timeout
	current_screen=wanted_screen
	move_screen(1,current_screen)



func _on_play_pressed():
	get_parent().switch_scenes_animation()

func _on_settings_pressed():
	change_screen(screens[1])

func _on_credits_pressed():
	pass

func _on_quit_pressed():
	get_tree().quit()



func _on_audio_pressed():
	pass # Replace with function body.

func _on_visual_pressed():
	pass # Replace with function body.

func _on_key_binds_pressed():
	pass # Replace with function body.

func _on_settings_back_pressed():
	change_screen(screens[0])
