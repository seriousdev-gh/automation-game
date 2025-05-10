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
	start_init()

func start_init() -> void:
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
		"grab": grab_item()
		"release":
			if held_item:
				held_item.snapToGrid()
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


func grab_item():
	if held_item:
		return

	var target = null

	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position + grab_offset
	query.collide_with_areas = true
	query.collision_mask = 0b10
	var results = get_world_2d().direct_space_state.intersect_point(query)
	for result in results:
		if result.collider.is_in_group("draggable"):
			target = result.collider.get_owner()
	
	if !target:
		return

	held_item = target
	grab_rotation = global_rotation - target.global_rotation

func _process(_delta):
	if held_item:
		held_item.updateAttachedTransforms(self, grab_offset, grab_rotation)
		
func snapToGrid():
	global_position = global_position.snapped(Vector2(100.0, 100.0))

func save():
	return {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"rotation": rotation,
		"program_text": program_text,
	}

func load_from(data):
	program_text = data["program_text"]


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("dynamic_item"):
		get_tree().get_root().get_node("main").on_dynamic_item_collision()
