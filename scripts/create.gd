extends TextureRect

@export var spawn_scene: PackedScene
@export var item_scene: PackedScene

signal on_node_create_started(new_node: Node2D)
signal on_node_create_finished

func _on_gui_input(event: InputEvent) -> void:
	if !Globals.is_stopped():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var rect = get_global_rect()
			var new_node = spawn_scene.instantiate()
			if item_scene:
				new_node.item_scene = item_scene
			new_node.global_position = rect.position + rect.size / 2.0
			on_node_create_started.emit(new_node)
		else:
			on_node_create_finished.emit()
