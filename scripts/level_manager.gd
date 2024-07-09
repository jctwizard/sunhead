extends Node2D
class_name level_manager

@export var timer : Label
@export var level_number : Label
@export var score_text : Label
@export var bumps_number : Label
@export var player_prefab : PackedScene
@export var transition_duration : float = 1.5

var current_level = -1
var level_node : Node = null

var current_timer = 0.0
var level_timer = 0.0

var levels = []
var best_score : float = 0.0
var best_time : float = 0.0
var best_level_times = {}
var current_bumps : int = 0
var best_bumps : int = 0

var player = null

var transitioning = false

func _ready():
	setup_levels()
	timer.text = ""
	level_number.text = ""
	bumps_number.text = ""
	
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
		
	if current_level > 0 and transitioning == false:
		current_timer += delta
		level_timer += delta
		
		update_timer()
		
		bumps_number.text = "bumps: " + str(current_bumps + player.bumps)
		
		if best_bumps != 0:
			bumps_number.text += "/" + str(best_bumps)
	
	if Input.is_key_pressed(KEY_SPACE):
		reset()
		
	if Input.is_key_pressed(KEY_R):
		if current_level != 0:
			if player != null:
				player.free()
				
			reset_game()
			load_level()

func update_timer():
	score_text.visible = false
	
	var time_string = str("%.2f" % current_timer)
	
	if best_time != 0:
		time_string += "/" + str("%.2f" % best_time)
	
	if best_level_times.has(str(current_level)):
		time_string += " (" + str("%.2f" % level_timer) + "/" + str("%.2f" % best_level_times[str(current_level)]) + ")"
	
	timer.text = time_string

func reset_game():
	current_level = 0
	current_timer = 0
	current_bumps = 0
	timer.text = ""
	bumps_number.text = ""
	level_number.text = ""
	score_text.visible = true

func reset():
	load_level()

func load_level():
	if levels.size() > current_level == false:
		if current_timer < best_time or best_time == 0.0:
			best_time = current_timer
			
		if current_bumps < best_bumps or best_bumps == 0:
			best_bumps = current_bumps
			
		var score = current_timer + current_bumps
			
		score_text.text = "score: " + str("%.2f" % current_timer) + " + " + str(current_bumps) + " = " + str("%.2f" % score)
		
		if score < best_score or best_score == 0.0:
			score_text.text += "\n" + "new best!"
			
			if best_score != 0.0:
				score_text.text += "\nprevious best: " + str("%.2f" % best_score)
				
			best_score = score
		elif best_score != 0.0:
			score_text.text += "\nbest: " + str("%.2f" % best_score)
		
		reset_game()
	
	if player != null:
		player.set_deferred("freeze", true)
		player.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	var previous_level = level_node
	
	level_node = levels[current_level]
	level_node.global_position.x -= 10000
	
	level_node.visible = true
	
	if previous_level != null:
		transitioning = true
	
		var level_original_y = level_node.global_position.y
		level_node.global_position.y -= get_viewport_rect().size.y
		
		var previous_level_original_y = previous_level.global_position.y
	
		var transition_time = 0.0
		
		while transition_time < transition_duration:
			transition_time += get_process_delta_time()
			previous_level.global_position.y = previous_level_original_y + get_viewport_rect().size.y * ease(transition_time / transition_duration, -2.0)
			level_node.global_position.y = level_original_y - get_viewport_rect().size.y * (1.0 - ease(transition_time / transition_duration, -2.0))
		
			await get_tree().process_frame
		
		level_node.global_position.y = level_original_y
		previous_level.global_position.y = previous_level_original_y
		previous_level.global_position.x += 10000
		previous_level.visible = false
		
		transitioning = false
	
	var goal = level_node.find_child("Goal")
	
	if goal != null and goal.is_connected("body_entered", triggered_goal) == false:
		goal.connect("body_entered", triggered_goal)
		
	var spawn = level_node.find_child("Spawn")
	
	if player != null:
		player.set_deferred("freeze", false)
		player.get_node("CollisionShape2D").set_deferred("disabled", false)
		player.reset()
		
	if spawn != null:
		if player == null:
			player = player_prefab.instantiate()
			add_child.call_deferred(player)
			player.global_position = spawn.global_position
		
	level_timer = 0
	
	level_number.text = str(current_level)
		
func next_level():
	if best_level_times.has(str(current_level)) == false or best_level_times[str(current_level)] < level_timer:
		best_level_times[str(current_level)] = level_timer
	
	if current_level > 0:
		current_bumps += player.bumps
	
	current_level = current_level + 1
	
	load_level()

func triggered_goal(body):
	if body == player:
		next_level()
