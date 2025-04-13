extends Node

enum {Stopped, Running, Paused}
var state = Stopped

func is_stopped() -> bool:
	return state == Stopped

func is_paused() -> bool:
	return state == Paused
	
func is_running() -> bool:
	return state == Running
