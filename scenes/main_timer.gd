extends Timer

func _on_cycle_timer_timeout() -> void:
	for item_spawn in %item_spawns.get_children():
		item_spawn.cycle(wait_time)
	for machine in %machines.get_children():
		machine.cycle(wait_time)
	for bot in %bots.get_children():
		bot.cycle(wait_time)
