extends CanvasLayer
@onready var state_label=$state_label
@onready var health_label=$health_label
@onready var fps_label=$fps_label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_label.text=str(Engine.get_frames_per_second())
