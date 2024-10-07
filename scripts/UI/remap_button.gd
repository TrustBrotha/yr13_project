extends Button

@export var action : String

var listening=false

# stops the unhandled process and displays the input text
func _ready():
	display_key()

func _input(event):
	if listening==true:
		if event is InputEventKey or (event is InputEventMouseButton and event.pressed):
			remap_key(event)
			button_pressed = false

# displays text version of the input event
func display_key():
	text = "%s"%InputMap.action_get_events(action)[0].as_text()

# remaps input
func remap_key(event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action,event)
	text = "%s" %event.as_text()

# if the button is toggled on, then the button is listening to inputs
func _on_toggled(toggled_on):
	await get_tree().create_timer(0.1).timeout
	if button_pressed:
		text = "---"
		mouse_filter=Control.MOUSE_FILTER_IGNORE
		listening=true
	else:
		display_key()
		mouse_filter=Control.MOUSE_FILTER_STOP
		listening=false



