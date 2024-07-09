extends RigidBody2D

@export var speed : float = 100
@export var default_sprite : Node2D
@export var bump_sprite : Node2D
@export var bump_show_duration : float = 0.1

var bumps : int = 0
var bump_show_time : float = 0.0

func _ready():
	name = "Player"
	connect("body_entered", _on_body_entered)
	bump_sprite.visible = false
	default_sprite.visible = true

func _process(delta):
	if bump_sprite.visible:
		bump_show_time += delta
		
		if bump_show_time >= bump_show_duration:
			bump_sprite.visible = false
			default_sprite.visible = true

func _physics_process(delta):
	if freeze == false:
		var movement = speed * (get_viewport().get_mouse_position() - global_position)
		apply_force(movement * delta)
	
func reset():
	set_deferred("linear_velocity", Vector2.ZERO)
	set_deferred("angular_velocity" , 0)
	bumps = 0
	
func _on_body_entered(_body : Node):
	bumps += 1
	
	bump_sprite.visible = true
	default_sprite.visible = false
	bump_show_time = 0.0
