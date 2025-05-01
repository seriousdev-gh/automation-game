extends Node2D

var left_ingredient: Node2D
var right_ingredient: Node2D

func kind() -> String:
	return "machines"

func snapToGrid():
	global_position = global_position.snapped(Vector2(100.0, 100.0))

func cycle(_duration: float):
	if left_ingredient && right_ingredient:
		left_ingredient.attach(right_ingredient)
		right_ingredient.attach(left_ingredient)

func _on_item_place_left_area_entered(area: Area2D) -> void:
	if !area.is_in_group("joinable"):
		return
	
	left_ingredient = area.get_owner()


func _on_item_place_left_area_exited(_area: Area2D) -> void:
	left_ingredient = null


func _on_item_place_right_area_entered(area: Area2D) -> void:
	if !area.is_in_group("joinable"):
		return
	right_ingredient = area.get_owner()


func _on_item_place_right_area_exited(_area: Area2D) -> void:
	right_ingredient = null

func save():
	return {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"rotation": rotation,
	}
