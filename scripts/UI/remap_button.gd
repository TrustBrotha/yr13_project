extends Button

# Controls which input will be changed
@export var action : String

# Controls when the button is listening
var listening = false

# Displays the input text for the original inputs
func _ready():
	display_key()


# Detects keyboard or mouse presses and assigns them to the button if in listening mode
func _input(event):
	if listening:
		if event is InputEventKey or (event is InputEventMouseButton and event.pressed):
			remap_key(event)
			button_pressed = false


# Displays text version of the input event
func display_key():
	text = "%s"%InputMap.action_get_events(action)[0].as_text()


# Remaps input
func remap_key(event):
	# Removes past key and replaces it with the new key
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	text = "%s" %event.as_text()



# If the button is toggled on, then the button is listening to inputs
# Also lets mouse buttons not be interpretted as clicking the button but rather inputs
func _on_toggled(toggled_on):
	await get_tree().create_timer(0.1).timeout
	if button_pressed:
		text = "---"
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		listening = true
	else:
		display_key()
		mouse_filter = Control.MOUSE_FILTER_STOP
		listening = false
