extends Node2D

@export var speech : Array[String] = ["hey there"]

var bubble : Label
var current_speech = 0

func _ready():
	bubble = get_node_or_null("Label")
	bubble.visible = false
	bubble.text = speech[current_speech]
	
func _process(delta):
	if bubble.visible and Input.is_action_just_pressed("speak"):
		current_speech += 1
		 
		if current_speech >= speech.size():
			current_speech = 0
			
		bubble.text = speech[current_speech]

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		bubble.visible = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		bubble.visible = false
