extends Node2D
@onready var tween_move: Tween = null
@onready var tween_rotate: Tween = null
const size = 100
var command_index = 0
@export var commands: Array[String] = ["right", "right", "grab", "left", "left", "release"]
var real_position: Vector2
var real_rotation: float
var grab_offset := Vector2(0, -100.0)
var grab_rotation := 0.0
var held_item: Node2D = null

func _ready() -> void:
	position = position.snapped(Vector2(50.0, 50.0))
	real_position = position
	real_rotation = rotation

func cycle(duration: float):
	if commands.is_empty():
		return
	
	var current_command = commands[command_index]
	command_index = (command_index + 1) % commands.size()
		
	match current_command:
		"left": 
			real_position += Vector2.LEFT * size
			move_to_position(real_position, duration)
		"right": 
			real_position += Vector2.RIGHT * size
			move_to_position(real_position, duration)
		"up": 
			real_position += Vector2.UP * size
			move_to_position(real_position, duration)
		"down": 
			real_position += Vector2.DOWN * size
			move_to_position(real_position, duration)
		"grab":
			if $reachRaycast.is_colliding():
				var target = $reachRaycast.get_collider().get_owner()
				grab_item(target)
		"release":
			if held_item:
				var updated: Array[Node2D] = []
				held_item.snapToGrid(updated)
				held_item = null
		"cw":
			real_rotation += PI/2.0
			#if real_rotation > 2 * PI:
				#real_rotation -= 2 * PI
			
			real_rotation = snappedf(real_rotation, PI / 2.0)
			rotate_to_angle(real_rotation, duration)
		"ccw":
			real_rotation -= PI/2.0
			#if real_rotation < 0:
				#real_rotation += 2 * PI
			
			real_rotation = snappedf(real_rotation, PI / 2.0)
			rotate_to_angle(real_rotation, duration)
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


func grab_item(item: Node2D):
	if held_item:
		return

	held_item = item
	grab_rotation = global_rotation - item.global_rotation

func _process(delta):
	if held_item:		
		var updated: Array[Node2D] = []
		held_item.updateAttachedTransforms(self, grab_offset, grab_rotation, updated)
