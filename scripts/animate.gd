extends Sprite2D

@export var skew_speed : float = 5
@export var skew_amount : float = 0.05

var timer = 0

func _process(delta):
	timer += delta
	skew = sin(timer * skew_speed) * skew_amount
