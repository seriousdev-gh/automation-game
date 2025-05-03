extends Node

enum {Stopped, Running, Paused}
var state = Stopped

func is_stopped() -> bool:
	return state == Stopped

func is_paused() -> bool:
	return state == Paused
	
func is_running() -> bool:
	return state == Running
	
func snapToGrid(node):
	node.global_position = node.global_position.snapped(Vector2(100.0, 100.0))
