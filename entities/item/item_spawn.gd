extends Node2D

@export var item_scene: PackedScene

func start_init():
	pass
	
func reset():
	pass

func cycle(_dt):
	print("Spawn cycle")
	print($Area2D.get_overlapping_areas())
	if $Area2D.get_overlapping_areas().is_empty():
		var new_node = item_scene.instantiate()
		new_node.global_position = global_position
		new_node.global_rotation = global_rotation
		get_tree().get_root().get_node("main/items").add_child(new_node)

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
		"item_scene" : item_scene.get_path(),
	}

func load_from(data):
	item_scene = load(data["item_scene"])
