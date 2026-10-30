extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

var speed = 220
var direction = Vector2(1,0)

var is_sitting = false

var screen_size = Vector2()
var window_size = Vector2(200,250)

var idle_timer = 0.0
var is_idling = false

var is_dragging  = false
var drag_offset = Vector2()

var voices = DisplayServer.tts_get_voices_for_language("en")
var chosen_voice_id = ""

func _ready():
	$Label.visible = false
	$Area2D.mouse_entered.connect(func():$AnimatedSprite2D.flip_v = true)
	$Area2D.mouse_exited.connect(func():$AnimatedSprite2D.flip_v = false)
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("walk")
	area.input_event.connect(_on_area_input)

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			
			var voice_list = DisplayServer.tts_get_voices()
			$Label.visible = true
			if voice_list.size() > 1:
				chosen_voice_id = voice_list[1]["id"]
			elif voice_list.size() >  0:
				chosen_voice_id = voice_list[0]["id"]
			if chosen_voice_id != "":
				DisplayServer.tts_speak("QUACKQUACK", chosen_voice_id)
			
		else:
			$Label.visible = false
			
	if event is InputEventMouseButton and event.pressed and event.double_click:
		OS.shell_open("https://web.toddleapp.com/platform/7750/courses")

func maybe_idle():
	if randf() < 0.3:
		is_idling = true
		idle_timer = randf_range(1.0, 3.0)
		var r = randi() % 3
		if r == 0:
			animated_sprite.play("idle")
			speed = 0



func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("sit"):
		is_sitting = !is_sitting
		if is_sitting:
			speed = 0
			animated_sprite.play("sit")
		else :
			speed = 220
			animated_sprite.play("walk")
	
	
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = 250
			animated_sprite.play("walk")
		return

	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction*speed*delta
	print(window_position)
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))

	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
		maybe_idle()
