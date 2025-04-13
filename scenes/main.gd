extends Node2D


func _ready() -> void:
	$items/item.attach($items/item3)
	$items/item3.attach($items/item)
	$items/item3.attach($items/item4)
	$items/item4.attach($items/item3)

func _on_cycle_timer_timeout() -> void:
	for bot in $bots.get_children():
		bot.cycle($cycleTimer.wait_time)

func _on_button_start_pressed() -> void:
	if Globals.is_stopped():
		for bot in $bots.get_children():
			bot.save()
		for item in $items.get_children():
			item.save()
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


var dragged_node: Node2D = null
var selected_node: Node2D = null
var drag_offset = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			on_mouse_left_button_pressed(event)
		else:
			on_mouse_left_button_released(event)

func on_mouse_left_button_pressed(event):
	deselect()
	check_mouse_collision_with_entities(event)

func check_mouse_collision_with_entities(event):
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

func on_mouse_left_button_released(event):
	stop_drag()

func start_drag(node):
	if Globals.is_stopped():
		dragged_node = node
		drag_offset = dragged_node.global_position - get_global_mouse_position()

func stop_drag():
	if dragged_node:
		dragged_node.global_position = dragged_node.global_position.snapped(Vector2(100.0, 100.0))
		if dragged_node.get_parent() == $items:
			dragged_node.updateAttachedTransformsSelf()
			
	dragged_node = null

func select(node):
	$Selection.visible = true
	selected_node = node
	if selected_node.get_parent() == $bots:
		%CodeEdit.text = selected_node.program_text

func deselect():
	if selected_node:
		$Selection.visible = false
	
	selected_node = null
	%CodeEdit.text = ""

func _process(delta):
	if dragged_node:
		dragged_node.global_position = get_global_mouse_position() + drag_offset
		if dragged_node.get_parent() == $items:
			dragged_node.updateAttachedTransformsSelf()
	
	if selected_node:
		$Selection.global_position = selected_node.global_position + Vector2.UP * 50


func _on_code_edit_text_changed() -> void:
	if selected_node && selected_node.get_parent() == $bots:
		selected_node.program_text = %CodeEdit.text
