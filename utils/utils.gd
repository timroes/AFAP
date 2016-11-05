extends Node

func get_camera():
	return get_node("/root/game/camera")

func get_scenes_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	var file = dir.get_next()
	while file != "":
		if file.extension() == "tscn":
			files.append("%s/%s" % [path, file])
		file = dir.get_next()
		
	dir.list_dir_end()
	return files
