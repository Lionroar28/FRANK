extends Node2D

var speed = 300
var direction = Vector2(1,0)

var screen_size = Vector2()
var window_size = Vector2(200,250)

func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())

func _physics_process(delta: float) -> void:
	
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction*speed*delta
	print(window_position)
	DisplayServer.window_set_position(Vector2i(window_position))
	
