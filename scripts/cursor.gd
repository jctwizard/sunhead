extends Node2D

@export var player : Node2D
@export var sling : Node2D
@export var sling_height : float = 200

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	
	update_sprites()

func _process(_delta):
	update_sprites()

func update_sprites():
	if player == null:
		player = get_node_or_null("../Player")
		
		if player == null:
			return
	
	global_position = get_viewport().get_mouse_position()
	
	global_rotation = player.global_position.angle_to_point(global_position) + deg_to_rad(90)
	
	sling.global_position = global_position + (player.global_position - global_position) / 2.0
	sling.rotation = player.global_position.angle_to_point(global_position) + deg_to_rad(90)
	var sling_distance = global_position.distance_to(player.global_position)
	sling.scale = Vector2(0.6 - 0.3 * (sling_distance / get_viewport().size.y), sling_distance / sling_height)
