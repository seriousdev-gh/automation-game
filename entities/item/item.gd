extends Node2D

var attachedItems: Array[ItemAttachmentPoint] = []

var starting_position: Vector2
var starting_rotation: float

func kind() -> String:
	return "items"
	
func _ready() -> void:
	save()
	
func save() -> void:
	starting_position = global_position.snapped(Vector2(100.0, 100.0))
	starting_rotation = global_rotation

func reset() -> void:
	global_position = starting_position
	global_rotation = starting_rotation

func attach(node: Node2D):
	var offset = node.global_position - global_position
	var relative_rotation = global_rotation - node.global_rotation
	var item = ItemAttachmentPoint.new(node, offset, relative_rotation)
	attachedItems.append(item)

func updateAttachedTransforms(parent: Node2D, offset: Vector2, relative_rotation: float, updated: Array[Node2D]):
	if updated.has(self):
		return
	updated.append(self)
	
	global_position = parent.global_position + offset.rotated(parent.global_rotation)
	global_rotation = parent.global_rotation - relative_rotation
	
	for item in attachedItems:
		item.node.updateAttachedTransforms(self, item.offset, item.rotation, updated)

func updateAttachedTransformsSelf():
	var updated: Array[Node2D] = []
	for item in attachedItems:
		item.node.updateAttachedTransforms(self, item.offset, item.rotation, updated)
	

func snapToGrid(updated: Array[Node2D]):
	if updated.has(self):
		return
	updated.append(self)
	
	global_position = global_position.snapped(Vector2(100.0, 100.0))
	global_rotation = snappedf(global_rotation, PI / 2.0)
	for item in attachedItems:
		item.node.snapToGrid(updated)
