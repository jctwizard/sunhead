extends RigidBody2D

@export var speed : float = 100

func _ready():
	name = "Player"

func _physics_process(delta):
	var movement = speed * (get_viewport().get_mouse_position() - global_position)
	apply_force(movement * delta)
	
func reset():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
