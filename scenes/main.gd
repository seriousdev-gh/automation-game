extends Node2D

# TODO: rename spawn to input

# z indexes:
# ui > items > machines, bots > item spawns

func _ready() -> void:
	update_selection()

func _on_button_start_pressed() -> void:
	if Globals.is_collided():
		return
	
	if Globals.is_stopped():
		for bot in $bots.get_children():
			bot.start_init()
		for item in $items.get_children():
			item.start_init()
		#save_game("_initial")
	if Globals.is_paused():
		for bot in $bots.get_children():
			bot.anim_continue()
		
	$cycleTimer.paused = false
	$cycleTimer.start()
	Globals.state = Globals.Running
	%StatusLine.text = "Status: Running"
	
func _on_button_pause_pressed() -> void:
	if Globals.is_collided():
		return
	
	pause()
	Globals.state = Globals.Paused
	%StatusLine.text = "Status: Paused"

func pause_and_fail():
	pause()
	Globals.state = Globals.Collided
	%StatusLine.text = "Status: Collision is not allowed"

func pause():
	if Globals.is_running():
		for bot in $bots.get_children():
			bot.anim_pause()
	
	$cycleTimer.paused = true

func _on_button_reset_pressed() -> void:
	if !Globals.is_stopped():
		for bot in $bots.get_children():
			bot.reset()
		for item in $items.get_children():
			item.queue_free()
		$cycleTimer.stop()
	
	Globals.state = Globals.Stopped
	%StatusLine.text = "Status: Stopped"


var drag_start_position: Vector2
var dragged_node: Node2D = null
var selected_node: Node2D = null
var drag_offset = Vector2.ZERO
var dragged_node_new = false

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			on_mouse_left_button_pressed(event)
		else:
			on_mouse_left_button_released(event)

func on_mouse_left_button_pressed(event):
	deselect()
	check_mouse_collision_with_entities(event)

func check_mouse_collision_with_entities(_event):
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collision_mask = 0b1
	var results = get_world_2d().direct_space_state.intersect_point(query)
	for result in results:
		if result.collider.is_in_group("draggable"):
			var node = result.collider.get_owner()
			select(node)
			start_drag(node)
			return

func check_collision(item: Node2D) -> bool:
	var item_collider = item.get_node("Area2D")
	
	var results = item_collider.get_overlapping_areas()
	for result in results:
		if result == item_collider: # ignore collision with itself
			continue
		if result.is_in_group("draggable"):
			return true
	return false

func on_mouse_left_button_released(_event):
	stop_drag()

func start_drag(node):
	if Globals.is_stopped():
		dragged_node = node
		drag_start_position = dragged_node.global_position
		drag_offset = dragged_node.global_position - get_global_mouse_position()

func stop_drag():
	if dragged_node:
		if in_play_area(dragged_node):
			if check_collision(dragged_node):
				if dragged_node_new:
					dragged_node.queue_free()
					deselect()
				else:
					dragged_node.global_position = drag_start_position
			else:
				Globals.snapToGrid(dragged_node)
			if dragged_node.has_method("updateAttachedTransformsSelf"):
				dragged_node.updateAttachedTransformsSelf()
		else:
			dragged_node.queue_free()
			deselect()
			
	dragged_node = null

func select(node):
	$Selection.visible = true
	selected_node = node
	update_selection()

func deselect():
	$Selection.visible = false
	selected_node = null
	update_selection()

func update_selection():
	if !selected_node || selected_node.kind() != "bots":
		%CodeEdit.text = ""
		%CodeEdit.editable = false
		%RobotInfo.text = "Select bot to edit program"
		return
		
	%CodeEdit.editable = true
	%CodeEdit.text = selected_node.program_text
	%RobotInfo.text = "Selected bot: " + str(selected_node.name)
	
	# fix missing caret, it is known issue in godot
	%CodeEdit.grab_focus()
	%CodeEdit.set_caret_blink_enabled(true)
	

func _process(_delta):
	if dragged_node:
		dragged_node.global_position = get_global_mouse_position() + drag_offset
		if dragged_node.has_method("updateAttachedTransformsSelf"):
			dragged_node.updateAttachedTransformsSelf()
			
		if Input.is_action_just_pressed("rotate_ccw"):
			dragged_node.rotation_degrees -= 90
			
		if Input.is_action_just_pressed("rotate_cw"):
			dragged_node.rotation_degrees += 90
	
	if selected_node:
		$Selection.global_position = selected_node.global_position + Vector2.UP * 50
		


func _on_code_edit_text_changed() -> void:
	if selected_node && selected_node.get_parent() == $bots:
		selected_node.program_text = %CodeEdit.text

func in_play_area(node: Node2D) -> bool:
	var area = node.get_node("Area2D")
	return !$DespawnArea.overlaps_area(area) && !$DespawnArea2.overlaps_area(area)


func _on_bots_child_order_changed() -> void:
	if !$bots:
		return
	
	for i in $bots.get_children().size():
		var bot = $bots.get_child(i)
		bot.name = str(i + 1)
		bot.get_node("NameLabel").text = str(i + 1)
		
	update_selection()


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		print(event)

func node_create_started(new_node: Node2D) -> void:
	dragged_node_new = true
	get_node(new_node.kind()).add_child(new_node)
	start_drag(new_node)
	select(new_node)

func node_create_finished() -> void:
	stop_drag()
	dragged_node_new = false


func _on_save_button_pressed() -> void:
	if Globals.is_stopped():
		SaveGame.run(self, "level")


func _on_load_button_pressed() -> void:
	if Globals.is_stopped():
		LoadGame.run(self, "level")
		deselect()
		update_selection()

func on_dynamic_item_collision():
	if Globals.is_running():
		pause_and_fail()
