extends Node2D
@onready var tween_move: Tween = null
@onready var tween_rotate: Tween = null
const size = 100
var command_index = 0
@export var commands: Array[String] = ["right", "right", "grab", "left", "left", "release"]
var position_shadow: Vector2
var rotation_shadow: float
var grab_offset := Vector2(0, -100.0)
var grab_rotation := 0.0

func _ready() -> void:
	position = position.snapped(Vector2(50.0, 50.0))
	position_shadow = position
	rotation_shadow = rotation

func cycle(duration: float):
	if commands.is_empty():
		return
	
	var current_command = commands[command_index]
	command_index = (command_index + 1) % commands.size()
		
	match current_command:
		"left": 
			position_shadow += Vector2.LEFT * size
			move_to_position(position_shadow, duration)
		"right": 
			position_shadow += Vector2.RIGHT * size
			move_to_position(position_shadow, duration)
		"up": 
			position_shadow += Vector2.UP * size
			move_to_position(position_shadow, duration)
		"down": 
			position_shadow += Vector2.DOWN * size
			move_to_position(position_shadow, duration)
		"grab":
			if $reachRaycast.is_colliding():
				var target = $reachRaycast.get_collider().get_owner()
				grab_item(target)
		"release":
			held_item = null
		"cw":
			rotation_shadow += PI/2.0
			rotate_to_angle(rotation_shadow, duration)
		"ccw":
			rotation_shadow -= PI/2.0
			rotate_to_angle(rotation_shadow, duration)
		_:
			push_warning("Unhandled command: %s" % current_command)
			
func rotate_to_angle(target_angle: float, duration: float):
	if tween_rotate:
		tween_rotate.kill()
		
	tween_rotate = create_tween()
	tween_rotate \
		.tween_property(self, "rotation", target_angle, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	
func move_to_position(target_position: Vector2, duration: float):
	if tween_move:
		tween_move.kill()
		
	tween_move = create_tween()
	tween_move \
		.tween_property(self, "position", target_position, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

var held_item: Node = null

func grab_item(item: Node2D):
	if held_item:
		return

	held_item = item
	grab_rotation = global_rotation - item.global_rotation

func _process(delta):
	if held_item:
		held_item.global_position = global_position + grab_offset.rotated(global_rotation)
		held_item.global_rotation = global_rotation - grab_rotation
