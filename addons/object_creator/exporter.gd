@tool
class_name Exporter
extends Node

signal object_exported

## creates new Exporter object which will then immediately export the object(s) to the chosen path
func _init(path: String, objects: Array, exportAsResource: bool):
	var directory = DirAccess.open(path)
	var fileNames = []
	for object in objects:
		fileNames.append(create_file_name(path, object, exportAsResource))
	
	for i in fileNames.size():
		var file = FileAccess.open(path + fileNames[i], FileAccess.WRITE)
		if not exportAsResource:
			file.store_string(JSON.stringify(objects[i]))
		emit_signal("object_exported")


func create_file_name(path: String, object: Object, exportAsResource: bool) -> String:
	var directory = DirAccess.open(path)
	var dirFiles = directory.get_files()
	var numberFiles = 0
	var fileEnding: String
	var fileName: String
	
	if exportAsResource:
		fileEnding = ".tres"
	else:
		fileEnding = ".json"
	
	for filePath in dirFiles:
		if filePath.ends_with(fileEnding):
			numberFiles += 1
	
	fileName = object.get_class() + "000" + str(numberFiles) + fileEnding
	return fileName
