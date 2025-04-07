extends Node2D
@onready var tween = null
const size = 100
var command_index = 0
@export var commands: Array[String] = ["left", "left", "down", "down", "right", "up", "right", "up"]

func cycle(duration: float):
	var current_command = commands[command_index]
	command_index = (command_index + 1) % commands.size()
	var new_position = position
	match current_command:
		"left": 
			new_position += Vector2.LEFT * size
		"right": 
			new_position += Vector2.RIGHT * size
		"up": 
			new_position += Vector2.UP * size
		"down": 
			new_position += Vector2.DOWN * size
			
	move_to_position(new_position, duration)
	
func move_to_position(target_position: Vector2, duration: float):
	if tween:
		tween.kill() # Stop previous tweens if any
		tween = create_tween()
	else:
		tween = create_tween()
	tween \
		.tween_property(self, "position", target_position, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
