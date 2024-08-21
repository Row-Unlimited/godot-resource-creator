@tool
class_name Exporter
extends Node

signal object_exported

## creates new Exporter object which will then immediately export the object(s) to the chosen path
func _init(path: String, objects: Array):
	var directory = DirAccess.open(path)
	var fileNames = []
	for object in objects:
		fileNames.append(create_file_name(path, object))
	
	for i in fileNames.size():
		var file = ResourceSaver.save(objects[i], path + fileNames[i])
		
		emit_signal("object_exported")


func create_file_name(path: String, object: Object) -> String:
	var directory = DirAccess.open(path)
	var dir_files = directory.get_files()
	var number_files = 0
	var fileName: String
	
	for filePath in dir_files:
		if filePath.ends_with(".tres"):
			number_files += 1
	
	fileName = object.get_class() + "000" + str(number_files) + ".tres"
	return fileName
