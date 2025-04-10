class_name ItemAttachmentPoint

var node: Node2D
var offset: Vector2
var rotation: float

func _init(n: Node2D, o: Vector2, r: float):
	node = n
	offset = o.snapped(Vector2(50.0, 50.0))
	rotation = snappedf(r, PI / 2.0)
