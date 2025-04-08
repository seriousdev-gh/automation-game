extends Node2D
@onready var tween = null
const size = 100
var command_index = 0
@export var commands: Array[String] = ["left", "left", "down", "down", "right", "up", "right", "up"]
var position_shadow: Vector2

func _ready() -> void:
	position_shadow = position

func cycle(duration: float):
	var current_command = commands[command_index]
	command_index = (command_index + 1) % commands.size()
	
	match current_command:
		"left": 
			position_shadow += Vector2.LEFT * size
		"right": 
			position_shadow += Vector2.RIGHT * size
		"up": 
			position_shadow += Vector2.UP * size
		"down": 
			position_shadow += Vector2.DOWN * size
			
	move_to_position(position_shadow, duration)
	
func move_to_position(target_position: Vector2, duration: float):
	if tween:
		tween.kill()
		tween = create_tween()
	else:
		tween = create_tween()
	tween \
		.tween_property(self, "position", target_position, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
