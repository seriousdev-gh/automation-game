extends Timer

func _on_cycle_timer_timeout() -> void:
	var item_inputs = get_tree().get_nodes_in_group("item_inputs")
	for item_input in item_inputs:
		item_input.cycle(wait_time)

	for machine in %machines.get_children():
		machine.cycle(wait_time)
	for bot in %bots.get_children():
		bot.cycle(wait_time)

	var item_outputs = get_tree().get_nodes_in_group("item_outputs")
	for item_output in item_outputs:
		item_output.cycle(wait_time)
