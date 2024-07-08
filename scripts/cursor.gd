extends Node2D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _process(delta):
	global_position = get_viewport().get_mouse_position()
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
