extends Node2D

func _ready() -> void:
	$item.attach($item3)
	$item3.attach($item)
	$item3.attach($item4)
	$item4.attach($item3)

func _on_cycle_timer_timeout() -> void:
	for bot in $bots.get_children():
		bot.cycle($cycleTimer.wait_time)


func _on_button_stop_pressed() -> void:
	$cycleTimer.stop()


func _on_button_start_pressed() -> void:
	$cycleTimer.start()
