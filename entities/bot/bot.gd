extends Node2D
var tween_move: Tween = null
var tween_rotate: Tween = null
const size = 100
var command_index = 0
var commands: Array[String] = []
var program_text: String

var held_item: Node2D = null
var grab_offset := Vector2(0, -100.0)
var grab_rotation := 0.0

# position and rotation of node used for animation
# real_position real_rotation store position and rotation at the end of cycle
var real_position: Vector2
var real_rotation: float

# remember values for putting things back to starting conditions
var starting_position: Vector2
var starting_rotation: float

func kind() -> String:
	return "bots"

func _ready() -> void:
	save()

func save() -> void:
	starting_position = global_position.snapped(Vector2(100.0, 100.0))
	starting_rotation = global_rotation
	real_position = starting_position
	real_rotation = starting_rotation
	
	commands = []
	for line in program_text.split("\n"):
		if line == "":
			continue
		commands.append(line)

func reset() -> void:
	if tween_move:
		tween_move.kill()
	if tween_rotate: 
		tween_rotate.kill()
	global_position = starting_position
	global_rotation = starting_rotation
	real_position = starting_position
	real_rotation = starting_rotation
	command_index = 0
	held_item = null

func anim_pause() -> void:
	if tween_move:
		tween_move.pause()
	if tween_rotate: 
		tween_rotate.pause()
		
func anim_continue() -> void:
	if tween_move and tween_move.is_valid():
		tween_move.play()
	if tween_rotate and tween_rotate.is_valid(): 
		tween_rotate.play()

func cycle(duration: float):
	if commands.is_empty():
		return
	
	var current_command = commands[command_index]
	command_index = (command_index + 1) % commands.size()
		
	match current_command:
		"left": move_to_position(Vector2.LEFT * size, duration)
		"right": move_to_position(Vector2.RIGHT * size, duration)
		"up": move_to_position(Vector2.UP * size, duration)
		"down": move_to_position(Vector2.DOWN * size, duration)
		"cw": rotate_to_angle(PI/2.0, duration)
		"ccw": rotate_to_angle(-PI/2.0, duration)
		"grab":
			if $reachRaycast.is_colliding():
				var target = $reachRaycast.get_collider().get_owner()
				grab_item(target)
		"release":
			if held_item:
				var updated: Array[Node2D] = []
				held_item.snapToGrid(updated)
				held_item = null
		"wait": pass
		_:
			push_warning("Unhandled command: %s" % current_command)
			
func rotate_to_angle(rotation_change: float, duration: float):
	real_rotation = snappedf(real_rotation + rotation_change, PI / 2.0)
	
	if tween_rotate:
		tween_rotate.kill()
		
	tween_rotate = create_tween()
	tween_rotate \
		.tween_property(self, "rotation", real_rotation, duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	
func move_to_position(position_change: Vector2, duration: float):
	real_position = (real_position + position_change).snapped(Vector2(100.0, 100.0))
	
	if tween_move:
		tween_move.kill()
		
	tween_move = create_tween()
	tween_move \
		.tween_property(self, "position", real_position, duration) \
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
		
