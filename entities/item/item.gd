extends Node2D

enum {Spawning,Free,Held}

var attachedItems: Array[ItemAttachmentPoint] = []

var starting_position: Vector2
var starting_rotation: float
var item_type: String
var state

# TODO: rename
var tween_temp: Tween = null

func kind() -> String:
	return "items"
	
func _ready() -> void:
	start_init()
	
func start_init() -> void:
	starting_position = global_position.snapped(Vector2(100.0, 100.0))
	starting_rotation = global_rotation
	$Label.text = item_type
	state = Spawning

func reset() -> void:
	global_position = starting_position
	global_rotation = starting_rotation
	attachedItems = []

func attach(node: Node2D):
	if attachedItems.any(func(x: ItemAttachmentPoint): return x.node == node):
		return
	
	var offset = node.global_position - global_position
	var relative_rotation = global_rotation - node.global_rotation
	var item = ItemAttachmentPoint.new(node, offset, relative_rotation)
	attachedItems.append(item)

func updateAttachedTransforms(parent: Node2D, offset: Vector2, relative_rotation: float, updated: Array[Node2D] = []):
	if updated.has(self):
		return
	updated.append(self)
	
	global_position = parent.global_position + offset.rotated(parent.global_rotation)
	global_rotation = parent.global_rotation - relative_rotation
	
	for item in attachedItems:
		item.node.updateAttachedTransforms(self, item.offset, item.rotation, updated)

func updateAttachedTransformsSelf():
	for item in attachedItems:
		item.node.updateAttachedTransforms(self, item.offset, item.rotation)
	

func snapToGrid(updated: Array[Node2D] = []):
	if updated.has(self):
		return
	updated.append(self)
	
	global_position = global_position.snapped(Vector2(100.0, 100.0))
	global_rotation = snappedf(global_rotation, PI / 2.0)
	for item in attachedItems:
		item.node.snapToGrid(updated)

func animate_input(dt):
	if tween_temp:
		tween_temp.kill()
		
	dt = dt * 0.8
		
	var initial_scale = $Sprite.scale
	var initial_modulate = $Sprite.modulate
	$Sprite.scale = Vector2(0.04, 0.04)
	$Sprite.modulate = Color(1.0, 1.0, 1.0, 0.5)
	tween_temp = get_tree().create_tween()
	tween_temp.tween_property($Sprite, "scale", initial_scale, dt)
	tween_temp.parallel().tween_property($Sprite, "modulate", initial_modulate, dt)
	tween_temp.tween_callback(set_state_free)
	
func animate_output(dt):
	if tween_temp:
		tween_temp.kill()
		
	dt = dt * 0.8
	
	$Area2D.queue_free()
	
	tween_temp = get_tree().create_tween()
	tween_temp.tween_property($Sprite, "scale", Vector2(0.04, 0.04), dt)
	tween_temp.parallel().tween_property($Sprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), dt)
	tween_temp.tween_callback(queue_free)

func set_state_held():
	state = Held
	
func set_state_free():
	state = Free
	
func is_free() -> bool:
	return state == Free

func save():
	# TODO: save attachedItems
	return {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"rotation": rotation,
	}


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("dynamic_item"):
		get_tree().get_root().get_node("main").on_dynamic_item_collision()
