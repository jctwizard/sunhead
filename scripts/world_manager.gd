extends Node2D
class_name world_manager

@export var timer_label : Label
@export var level_label : Label
@export var score_label : Label
@export var bumps_label : Label
@export var spawn : Node2D
@export var goals : Array[Area2D]
@export var player_prefab : PackedScene
@export var transition_duration : float = 1.5
@export var camera : Camera2D

var current_timer = 0.0

var best_score : float = 0.0
var best_time : float = 0.0
var best_bumps : int = 0

var player = null

var transitioning = false

var level_coordinates = Vector2.ZERO

func _ready():
	timer_label.text = ""
	level_label.text = ""
	bumps_label.text = ""
	
	for goal in goals:
		goal.connect("body_entered", triggered_goal)
	
	spawn_player()
	
func spawn_player():
	if spawn != null:
		if player != null:
			player.free()
			
		player = player_prefab.instantiate()
		add_child.call_deferred(player)
		player.global_position = spawn.global_position
		
		player.camera = camera
		
func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
	await update_camera()
		
	if level_coordinates != Vector2.ZERO and transitioning == false:
		current_timer += delta
		
		update_timer()
		
		bumps_label.text = "bumps: " + str(player.bumps)
		
		if best_bumps != 0:
			bumps_label.text += "/" + str(best_bumps)
		
	if Input.is_key_pressed(KEY_R):
		if player != null:
			player.free()
			
		reset_game()

func update_camera():
	if player != null and camera != null and transitioning == false:
		if player.global_position.x < camera.global_position.x:
			await transition(-1, 0)
		elif player.global_position.x > camera.global_position.x + get_viewport_rect().size.x:
			await transition(1, 0)
		elif player.global_position.y < camera.global_position.y:
			await transition(0, -1)
		elif player.global_position.y > camera.global_position.y + get_viewport_rect().size.y:
			await transition(0, 1)

func transition(x, y):
	transitioning = true
	
	if level_coordinates == Vector2.ZERO:
		if player != null:
			player.bumps = 0
			current_timer = 0
			score_label.visible = false
			level_label.visible = true
	
	level_coordinates += Vector2(x, y)
	
	if level_coordinates == Vector2.ZERO:
		if player != null:
			bumps_label.text = ""
			timer_label.text = ""
			score_label.visible = true
			level_label.visible = false
			
	level_label.text = str(level_coordinates.x) + "." + str(-level_coordinates.y)
	
	if player != null:
		player.stop()
	
	var transition_time = 0
	var initial_camera_position = camera.global_position
	var target_camera_position = initial_camera_position + Vector2(x * get_viewport_rect().size.x, y * get_viewport_rect().size.y)
	
	# skip screen_transition
	if Input.is_key_pressed(KEY_H):
		pass
	else:
		while transition_time < transition_duration:
			transition_time += get_process_delta_time()
			camera.global_position = lerp(initial_camera_position, target_camera_position, ease(transition_time / transition_duration, -2.0))
			
			await get_tree().process_frame
		
	camera.global_position = target_camera_position
	
	if player != null:
		player.reset()
		player.go()
		
	transitioning = false

func update_timer():
	score_label.visible = false
	
	var time_string = str("%.2f" % current_timer)
	
	if best_time != 0:
		time_string += "/" + str("%.2f" % best_time)
	
	timer_label.text = time_string

func reset_game():
	if camera != null:
		camera.global_position = Vector2.ZERO
		
	level_coordinates = Vector2.ZERO
	
	current_timer = 0
	
	timer_label.text = ""
	bumps_label.text = ""
	level_label.text = ""
	
	score_label.visible = true
	
	spawn_player()

func triggered_goal(body):
	if body == player:
		if current_timer < best_time or best_time == 0.0:
			best_time = current_timer
			
		if player.bumps < best_bumps or best_bumps == 0:
			best_bumps = player.bumps
		
		var score = current_timer + player.bumps
			
		score_label.text = "score: " + str("%.2f" % current_timer) + " + " + str(player.bumps) + " = " + str("%.2f" % score)
		
		if score < best_score or best_score == 0.0:
			score_label.text += "\n" + "new best!"
			
			if best_score != 0.0:
				score_label.text += "\nprevious best: " + str("%.2f" % best_score)
				
			best_score = score
		elif best_score != 0.0:
			score_label.text += "\nbest: " + str("%.2f" % best_score)
		
		reset_game()
