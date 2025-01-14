class_name DirHelper
extends Object


 ## recursive function that searches from the given directory for all files that end with fileType
static func search_filetypes_in_directory(fileType: String, directory: String, ignored_directories=[]) -> Array:
	var filePathArray = []
	var current_directory = DirAccess.open(directory)
	var directory_paths = current_directory.get_directories()
	var filePaths = current_directory.get_files()
	
	for path in filePaths:
		if path.ends_with(fileType):
			filePathArray.append(directory + "/" + path)
	
	for path in directory_paths:
		if not Helper.check_string_contains_array(ignored_directories, path):
			filePathArray.append_array(search_filetypes_in_directory(fileType, directory + "/" + path, ignored_directories))
	
	filePathArray = filePathArray.map(func(x:String): return x.replace("res:///", "res://"))
	
	return filePathArray

static func return_script_paths(excluded_directories: Array = []):
	
	pass
