extends RigidBody2D

@export var speed : float = 100

func _physics_process(delta):
	var movement = speed * (get_viewport().get_mouse_position() - global_position)
	apply_force(movement * delta)
