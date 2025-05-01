extends Node2D


func _ready() -> void:
	update_selection()

func _on_cycle_timer_timeout() -> void:
	for bot in $bots.get_children():
		bot.cycle($cycleTimer.wait_time)
	for machine in $machines.get_children():
		machine.cycle($cycleTimer.wait_time)

func _on_button_start_pressed() -> void:
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
	if Globals.is_running():
		for bot in $bots.get_children():
			bot.anim_pause()
		$cycleTimer.paused = true
		
	Globals.state = Globals.Paused
	%StatusLine.text = "Status: Paused"

func _on_button_reset_pressed() -> void:
	if Globals.is_running() || Globals.is_paused():
		for bot in $bots.get_children():
			bot.reset()
		for item in $items.get_children():
			item.reset()
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
	var item_collider = item.find_child("Area2D", false)
	
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
				dragged_node.snapToGrid()
			if dragged_node.get_parent() == $items:
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
		%RobotInfo.text = "Select bot to edit program"
		return
		
	%CodeEdit.text = selected_node.program_text
	%RobotInfo.text = "Selected bot: " + str(selected_node.name)

func _process(_delta):
	if dragged_node:
		dragged_node.global_position = get_global_mouse_position() + drag_offset
		if dragged_node.get_parent() == $items:
			dragged_node.updateAttachedTransformsSelf()
	
	if selected_node:
		$Selection.global_position = selected_node.global_position + Vector2.UP * 50


func _on_code_edit_text_changed() -> void:
	if selected_node && selected_node.get_parent() == $bots:
		selected_node.program_text = %CodeEdit.text

func in_play_area(node: Node2D) -> bool:
	var area = node.find_child("Area2D")
	return !$DespawnArea.overlaps_area(area) && !$DespawnArea2.overlaps_area(area)


func _on_bots_child_order_changed() -> void:
	if !$bots:
		return
	
	for i in $bots.get_children().size():
		var bot = $bots.get_child(i)
		bot.name = str(i + 1)
		bot.find_child("NameLabel").text = str(i + 1)
		
	update_selection()


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		print(event)

func node_create_started(new_node: Node2D) -> void:
	dragged_node_new = true
	find_child(new_node.kind()).add_child(new_node)
	start_drag(new_node)
	select(new_node)

func node_create_finished() -> void:
	stop_drag()
	dragged_node_new = false


func _on_save_button_pressed() -> void:
	if Globals.is_stopped():
		save_game("level")

func save_game(file: String):
	var save_file = FileAccess.open("user://" + file + ".json", FileAccess.WRITE)
	for node in simulation_nodes():
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
	
func load_game(file: String):
	var path = "user://" + file + ".json"
	if not FileAccess.file_exists(path):
		print("Savefile not found. Path: ", path)
		return # Error! We don't have a save to load.

	for node in simulation_nodes():
		node.queue_free()

	var save_file = FileAccess.open(path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])

func simulation_nodes():
	return $bots.get_children() + $items.get_children() + $machines.get_children()

func _on_load_button_pressed() -> void:
	if Globals.is_stopped():
		load_game("level")
		deselect()
		update_selection()
