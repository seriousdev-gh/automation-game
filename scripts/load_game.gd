class_name LoadGame

static func run(main: Node, file: String):
	var path = "user://" + file + ".json"
	if not FileAccess.file_exists(path):
		print("Savefile not found. Path: ", path)
		return # Error! We don't have a save to load.

	for node in main.get_tree().get_nodes_in_group("saveable"):
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

		var new_object = load(node_data["filename"]).instantiate()
		main.get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		new_object.rotation = node_data["rotation"]

		if new_object.has_method("load_from"):
			new_object.load_from(node_data)
