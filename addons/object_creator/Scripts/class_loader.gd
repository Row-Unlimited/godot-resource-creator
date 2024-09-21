@tool
class_name ClassLoader
extends Node
## searches through project structure (excluding .git/.godot) and fetches all custom classes that can be created

const plugin_configPath = "res://addons/object_creator/PluginConfig.tres"
var plugin_config = preload(plugin_configPath)

func check_for_integration() -> bool:
	if plugin_config.isIntegrated:
		return true
	else:
		return false

func return_integrated_classes() -> Array:
	var ClassArray = []
	for path in plugin_config.integrated_classPaths:
		ClassArray.append(ClassObject.new(path, return_file_name_from_path(path)))
	
	return ClassArray


func return_possible_classes() -> Array:
	var class_array = []
	var start_path = "res://"
	var filePaths: Array = search_filetypes_in_directory(".gd", start_path)
	filePaths.append_array(search_filetypes_in_directory(".cs", start_path))
	var temp_classes = []
	
	for path in filePaths:
		var name = return_file_name_from_path(path)
		temp_classes.append(ClassObject.new(path, name))
	
	# maybe add functionality that checks each class for a certain prerequisite
	class_array = temp_classes
	
	return class_array


## recursive function that searches from the given directory for all files that end with fileType
func search_filetypes_in_directory(fileType: String, directory: String) -> Array:
	var filePathArray = []
	var current_directory = DirAccess.open(directory)
	var directory_paths = current_directory.get_directories()
	var filePaths = current_directory.get_files()
	
	for path in filePaths:
		if path.ends_with(fileType):
			filePathArray.append(directory + "/" + path)
	
	for path in directory_paths:
		if not Helper.check_string_contains_array(plugin_config.ignored_directories, path):
			filePathArray.append_array(search_filetypes_in_directory(fileType, directory + "/" + path))
	
	return filePathArray

func return_file_name_from_path(path: String) -> String:
	var return_string = path.reverse()
	var end_point: int
	
	for i in return_string.length():
		if return_string[i] == "/":
			return_string = return_string.substr(0, i)
			break
		i += 1
	
	return_string = return_string.reverse()
	return return_string
