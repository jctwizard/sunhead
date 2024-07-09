extends Node2D

@export var speech : Array[String] = ["hey there"]
@export var bump_cooldown_duration : float = 0.5

var bubble : Label
var current_speech = -1
var bump_cooldown_time = 0.0

func _ready():
	bubble = get_node_or_null("Label")
	bubble.visible = false
	bubble.text = speech[current_speech]
	
	if get_node_or_null("CharacterCollision") != null:
		connect("body_entered", _on_body_entered)
	
func _process(_delta):
	if bump_cooldown_time > 0.0:
		bump_cooldown_time -= _delta
	
	if is_visible_in_tree() == false:
		bubble.visible = false
		bump_cooldown_time = 0.0

func _on_body_entered(body : Node):
	if body.name == "Player" and bump_cooldown_time <= 0:
		bump_cooldown_time = bump_cooldown_duration
		
		bubble.visible = true
		current_speech += 1
		 
		if current_speech >= speech.size():
			current_speech = 0
			
		bubble.text = speech[current_speech]
