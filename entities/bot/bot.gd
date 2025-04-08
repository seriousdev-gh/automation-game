extends Node2D
@onready var tween = null
const size = 100
var command_index = 0
@export var commands: Array[String] = ["right", "right", "grab", "left", "left", "release"]
var position_shadow: Vector2
var grab_offset := Vector2(0, -100)

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
		"grab":
			if $reachRaycast.is_colliding():
				var target = $reachRaycast.get_collider().get_owner()
				grab_item(target)
		"release":
			held_item = null
		_:
			push_warning("Unhandled command: %s" % current_command)
			
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

var held_item: Node = null

func grab_item(item):
	if held_item:
		return

	held_item = item

func _process(delta):
	if held_item:
		held_item.global_position = global_position + grab_offset.rotated(global_rotation)
		# TODO: correct rotation
