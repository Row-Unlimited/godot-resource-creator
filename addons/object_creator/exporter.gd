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
	var dirFiles = directory.get_files()
	var numberFiles = 0
	var fileName: String
	
	for filePath in dirFiles:
		if filePath.ends_with(".tres"):
			numberFiles += 1
	
	fileName = object.get_class() + "000" + str(numberFiles) + ".tres"
	return fileName
