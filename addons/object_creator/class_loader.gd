@tool
class_name ClassLoader
extends Node

const userInformationPath = "res://addons/object_creator/UserInformation.tres"
var userInformation = preload(userInformationPath)

func check_for_integration() -> bool:
	if userInformation.isIntegrated:
		return true
	else:
		return false

func return_integrated_classes() -> Array:
	var ClassArray = []
	for path in userInformation.integratedClassPaths:
		ClassArray.append(ClassObject.new(path, return_file_name_from_path(path)))
	
	return ClassArray

func return_possible_classes() -> Array:
	var classArray = []
	var startPath = "res://"
	var filePaths: Array = search_filetypes_in_directory(".gd", startPath)
	filePaths.append_array(search_filetypes_in_directory(".cs", startPath))
	var tempClasses = []
	
	for path in filePaths:
		var name = return_file_name_from_path(path)
		tempClasses.append(ClassObject.new(path, name))
	
	# maybe add functionality that checks each class for a certain prerequisite
	classArray = tempClasses
	
	return classArray

## recursive function that searches from the given directory for all files that end with fileType
func search_filetypes_in_directory(fileType: String, directory: String) -> Array:
	var filePathArray = []
	var currentDirectory = DirAccess.open(directory)
	var directoryPaths = currentDirectory.get_directories()
	var filePaths = currentDirectory.get_files()
	
	for path in filePaths:
		if path.ends_with(fileType):
			filePathArray.append(directory + "/" + path)
	
	for path in directoryPaths:
		if not (path.contains(".git") or path.contains(".godot")):
			filePathArray.append_array(search_filetypes_in_directory(fileType, directory + "/" + path))
	
	return filePathArray


func return_file_name_from_path(path: String) -> String:
	var returnString = path.reverse()
	var endPoint: int
	
	for i in returnString.length():
		if returnString[i] == "/":
			returnString = returnString.substr(0, i)
			break
		i += 1
	
	returnString = returnString.reverse()
	return returnString
