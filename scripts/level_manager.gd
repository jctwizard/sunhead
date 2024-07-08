extends Node2D
class_name level_manager

@export var timer : Label
@export var level_number : Label
@export var start_text : Label
@export var player_prefab : PackedScene

var current_level = -1
var level_node : Node = null

var current_timer = 0.0
var level_timer = 0.0

var levels = []
var best_time = 0.0
var best_level_times = {}

var player = null

var started = false

func _ready():
	start_text.visible = true
	setup_levels()
	
func setup_levels():
	var level_count = 0
	
	while(current_level == -1):
		var level = get_node_or_null("../Level" + str(level_count))
		if level != null:
			level.visible = false
			level.global_position.x += 10000
			levels.append(level)
			level_count += 1
		else:
			current_level = 0
			
	load_level()
	
func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
	if started == false:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			start_text.visible = false
			started = true
			
			if player != null:
				player.set_deferred("freeze", false)
				player.reset()
		else:
			return
	
	current_timer += delta
	level_timer += delta
	
	update_timer()
	
	if Input.is_key_pressed(KEY_SPACE):
		reset()
		
	if Input.is_key_pressed(KEY_R):
		reset_game()

func update_timer():
	var time_string = str("%.2f" % current_timer)
	
	if best_time != 0:
		time_string += " / " + str("%.2f" % best_time)
	
	if best_level_times.has(str(current_level)):
		time_string += " (" + str("%.2f" % level_timer) + " / " + str("%.2f" % best_level_times[str(current_level)]) + ")"
	
	timer.text = time_string

func reset_game():
	current_level = 0
	current_timer = 0
	start_text.visible = true
	started = false

	if player != null:
		player.set_deferred("freeze", true)

func reset():
	load_level()

func load_level():
	if levels.size() > current_level == false:
		if current_timer < best_time or best_time == 0.0:
			best_time = current_timer

		reset_game()
	
	var new_level = levels[current_level]

	if level_node != null:
		level_node.visible = false
		level_node.global_position.x += 10000
	
	level_node = new_level
	level_node.global_position.x -= 10000
	level_node.visible = true
	
	var goal = level_node.find_child("Goal")
	
	if goal != null and goal.is_connected("body_entered", triggered_goal) == false:
		goal.connect("body_entered", triggered_goal)
		
	var spawn = level_node.find_child("Spawn")
	
	if player != null:
		player.free()
	
	if spawn != null:
		player = player_prefab.instantiate()
		player.global_position = spawn.global_position
		add_child.call_deferred(player)
		
		if started == false:
			player.set_deferred("freeze", true)
		
	level_timer = 0
	
	level_number.text = str(current_level)
		
func next_level():
	if best_level_times.has(str(current_level)) == false or best_level_times[str(current_level)] < level_timer:
		best_level_times[str(current_level)] = level_timer
	
	current_level = current_level + 1
	
	load_level()

func triggered_goal(body):
	if body == player:
		next_level()
