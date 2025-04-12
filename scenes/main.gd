extends Node2D

enum State {Stopped, Running, Paused}
var state: State = State.Stopped

func _ready() -> void:
	$items/item.attach($items/item3)
	$items/item3.attach($items/item)
	$items/item3.attach($items/item4)
	$items/item4.attach($items/item3)

func _on_cycle_timer_timeout() -> void:
	for bot in $bots.get_children():
		bot.cycle($cycleTimer.wait_time)

func _on_button_start_pressed() -> void:
	if state == State.Stopped:
		for bot in $bots.get_children():
			bot.save()
		for item in $items.get_children():
			item.save()
	if state == State.Paused:
		for bot in $bots.get_children():
			bot.anim_continue()
		
	$cycleTimer.paused = false
	$cycleTimer.start()
	state = State.Running
	%StatusLine.text = "Status: Running"
	
func _on_button_pause_pressed() -> void:
	if state == State.Running:
		for bot in $bots.get_children():
			bot.anim_pause()
		$cycleTimer.paused = true
		
	state = State.Paused
	%StatusLine.text = "Status: Paused"

func _on_button_reset_pressed() -> void:
	if state == State.Running || state == State.Paused:
		for bot in $bots.get_children():
			bot.reset()
		for item in $items.get_children():
			item.reset()
		$cycleTimer.stop()
	
	state = State.Stopped
	%StatusLine.text = "Status: Stopped"
