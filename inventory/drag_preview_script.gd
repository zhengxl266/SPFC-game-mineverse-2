extends Control
var offset: Vector2

func _ready():
	offset = -size/2

func _process(delta):
	global_position = get_global_mouse_position() - size/2
