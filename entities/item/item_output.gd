extends Node2D

@export var expected_item_kind: String

func _ready() -> void:
	start_init()
	
func start_init():
	$Label.text = expected_item_kind
	
func reset():
	pass

func cycle(dt):
	for area in $Area2D.get_overlapping_areas():
		var node = area.get_parent()
		if node.kind() != "items":
			continue
		
		if node.item_type == expected_item_kind && node.is_free():
			node.animate_output(dt)

func kind() -> String:
	return "item_spawns"

func snapToGrid():
	global_position = global_position.snapped(Vector2(100.0, 100.0))

func save():
	return {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"rotation": rotation,
		"expected_item_kind": expected_item_kind,
	}
	

func load_from(data):
	expected_item_kind = data["expected_item_kind"]
	start_init()
