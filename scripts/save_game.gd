class_name SaveGame

static func run(main: Node, file: String):
	var content = []
	
	for node in main.get_tree().get_nodes_in_group("saveable"):
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		var node_data = node.call("save")
		var json_string = JSON.stringify(node_data)
		content.push_back(json_string)
	
	var save_file = FileAccess.open("user://" + file + ".json", FileAccess.WRITE)
	
	for line in content:
		save_file.store_line(line)
