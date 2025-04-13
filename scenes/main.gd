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
var drag_offset = Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			on_mouse_left_button_pressed(event)
		else:
			on_mouse_left_button_released(event)

func on_mouse_left_button_pressed(event):
	if !Globals.is_stopped():
		return
	
	var mouse_pos = get_global_mouse_position()
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collision_mask = 0b1
	var results = get_world_2d().direct_space_state.intersect_point(query)
	for result in results:
		if result.collider.is_in_group("draggable"):
			dragged_node = result.collider.get_owner()
			drag_offset = dragged_node.global_position - mouse_pos
			break

func on_mouse_left_button_released(event):
	if dragged_node:
		dragged_node.global_position = dragged_node.global_position.snapped(Vector2(100.0, 100.0))
		if dragged_node.get_parent() == $items:
			dragged_node.updateAttachedTransformsSelf()
		dragged_node = null

func _process(delta):
	if dragged_node:
		dragged_node.global_position = get_global_mouse_position() + drag_offset
		if dragged_node.get_parent() == $items:
			dragged_node.updateAttachedTransformsSelf()
