extends Node2D

var attachedItems: Array[ItemAttachmentPoint] = []

var starting_position: Vector2
var starting_rotation: float

func kind() -> String:
	return "items"
	
func _ready() -> void:
	start_init()
	
func start_init() -> void:
	starting_position = global_position.snapped(Vector2(100.0, 100.0))
	starting_rotation = global_rotation

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

func save():
	# TODO: save attachedItems
	return {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"rotation": rotation,
	}
