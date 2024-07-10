extends Node2D

@export var speech : Array[String] = ["hey there"]
@export var max_bubble_width : float = 100
@export var bump_cooldown_duration : float = 0.5
@export var show_duration : float = 5.0

var bubble : Label
var current_speech = -1
var bump_cooldown_time = 0.0
var initial_bubble_size : Vector2
var initial_bubble_position : Vector2
var show_time : float = 0.0

func _ready():
	bubble = get_node_or_null("Label")
	bubble.visible = false
	
	initial_bubble_size = bubble.size
	initial_bubble_position = bubble.position
	
	if get_node_or_null("CharacterCollision") != null:
		connect("body_entered", _on_body_entered)
	
func _process(_delta):
	if bump_cooldown_time > 0.0:
		bump_cooldown_time -= _delta
	
	if is_visible_in_tree() == false:
		bubble.visible = false
		bump_cooldown_time = 0.0
		
	if bubble.visible == true:
		if show_time > 0.0:
			show_time -= _delta
			
			if show_time <= 0.0:
				bubble.visible = false

func _on_body_entered(body : Node):
	if body.name == "Player" and bump_cooldown_time <= 0:
		bump_cooldown_time = bump_cooldown_duration
		
		show_time = show_duration
		
		bubble.visible = true
		
		bubble.text = ""
		
		bubble.autowrap_mode = TextServer.AUTOWRAP_OFF
		bubble.size = initial_bubble_size
		bubble.position = initial_bubble_position
		 
		current_speech += 1
		
		if current_speech >= speech.size():
			current_speech = 0
			
		bubble.text = " " + speech[current_speech] + " "
		
		fix_bubble_size.call_deferred()

func fix_bubble_size():
	if bubble.size.x > max_bubble_width:
		bubble.text = ""
		bubble.autowrap_mode = TextServer.AUTOWRAP_WORD
		bubble.size.x = max_bubble_width
		bubble.text = speech[current_speech]
	
	bubble.position.x = -bubble.size.x / 2
	
	if bubble.text == "  ":
		bubble.visible = false
