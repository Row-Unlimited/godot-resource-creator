@tool
class_name Helper
extends Object

static func check_string_contains_array(stringArray: Array, checkString: String):
	for string: String in stringArray:
		if checkString.contains(string):
			return true
	return false

## updates one objects values with another objects ones[br]
## [param skipped_properties]: will skip certain variables if their names match[br]
## [param ignore_propery_overflow]: 	if set to true the func will ignore it if the update_object has variables
## 									that the base_object has not[br]
## [param ignore_null_values]: if set to false, null values from the update_object will also be used to overwrite the base_object
static func update_object(base_object: Object, update_object: Object, skipped_properties=[], ignore_propery_overflow = false, ignore_null_values = true):
	var new_properties = update_object.get_property_list()
	var old_property_keys = []
	for property in base_object.get_property_list():
		old_property_keys.append(property["name"])

	for property in new_properties:
		
		var property_name = property["name"]
		if property_name in skipped_properties:
			continue
		# check if the property is in the value or if it should be ignored if it isn't
		if not (old_property_keys.has(property_name) or ignore_propery_overflow):
			return null
		
		var update_value = update_object.get(property_name)
		if update_value or not ignore_null_values:
			base_object.set(property_name, update_value)

## compares arrays and returns whether they are the same.[br]
## [param ignore_order]: if set to false, the method will also check whether the elements
## are in the correct order
static func compare_arrays(arr1: Array, arr2: Array, ignore_order=true):
	if arr1.size() != arr2.size():
		return false
	for i in arr1.size():
		if ignore_order:
			if not arr2.has(arr1[i]):
				return false
		else:
			if typeof(arr1[i]) != typeof(arr2[i]):
				return false
			else:
				if arr1[i] != arr2[i]:
					return false
	
	return true

## prints the name of all variables and their current values of an object[br]
## [param skipped_properties]: will skip certain variables if their names are the same
static func print_object_values(obj: Object, ignore_null_values=true, skipped_properties=[]):
	var properties = obj.get_property_list()
	for property in properties:
		var prop_name = property["name"]
		var prop_value = obj.get(prop_name)
		if prop_name in skipped_properties or (ignore_null_values and not prop_value):
			continue
		else:
			var value_string = prop_name + ": " + str(obj.get(prop_name))
			print(value_string)
			print("--".rpad(value_string.length(), "-"))

static func remove_items_from_path(path: String, number_items : int):
	var path_reverse = path.reverse()
	for i in number_items:
		var signifier_index = path_reverse.find("/")
		if signifier_index == -1:
			return null
		path_reverse = path_reverse.substr(signifier_index + 1)
	return path_reverse.reverse()

## takes a String in the default form we receive when using the str() function on a string object [br]
## example: (1, 2, 3) [br]
## and returns a Vector2/3/4 [br]
static func string_to_vector(vec_str : String):
	var regex = RegEx.new()
	regex.compile(r"(?<number>([1-9]+[0-9]*|0)\.*([0-9]*))[,\)]")
	var numbers = []
	for result in regex.search_all(vec_str):
		numbers.append(result.get_string("number").to_float())
	
	match numbers.size():
		2:
			return Vector2(numbers[0], numbers[1])
		3:
			return Vector3(numbers[0], numbers[1], numbers[2])
		4:
			return Vector4(numbers[0], numbers[1], numbers[2], numbers[3])
		_:
			return null

static func filter_lines(single_string: String, filter_terms : Array[String]) -> Array[String]:
	var filtered_lines = [] as Array[String]
	var single_string_lines = single_string.split("\n")
	for term in filter_terms:
		for i in single_string_lines.size():
			var current_line = single_string_lines[i]
			if term in current_line:
				filtered_lines.append(current_line)

	return filtered_lines
	

static func prune_string(string: String, start: String, end: String="") -> String:
	var i_start = string.find(start) + start.length() if start in string else 0
	string = string.substr(i_start)
	
	if end:
		string = string.reverse()
		var i_end = string.find(end) + end.length() if end in string else 0
		string = string.substr(i_end).reverse()
	return string.strip_edges()


static func to_printable_str(input, max_line_length=50) -> String:
	var return_string = ""
	var regular_object_strings: Array[String] = []
	match typeof(input):
		TYPE_ARRAY:
			var array_string = ""
			return_string += "\nArray:\n"
			return_string += "--".rpad(max_line_length, "-")
			
			var line_length = 0

			for item in input:
				if (typeof(item) == TYPE_ARRAY or typeof(item) == TYPE_DICTIONARY):
					if regular_object_strings:
						array_string += _format_to_lines(regular_object_strings)
						regular_object_strings = []
					array_string += to_printable_str(item) + "\n"
				else:
					regular_object_strings.append(str(item))
			if regular_object_strings:
						array_string += _format_to_lines(regular_object_strings)
						regular_object_strings = []
			
			array_string = array_string.indent("   ")
			return_string += array_string

		TYPE_DICTIONARY:
			var dict_string = ""
			return_string += "Dictionary:\n"
			return_string += "--".rpad(max_line_length, "-")

			var line_length = 0

			for key in input.keys():
				var item = input[key]
				if (typeof(item) == TYPE_ARRAY or typeof(item) == TYPE_DICTIONARY):
					if regular_object_strings:
						dict_string += _format_to_lines(regular_object_strings)
						regular_object_strings = []
					dict_string +='\n"' + key + '"' + ": " + to_printable_str(item) + "\n"
				else:
					regular_object_strings.append('"' + key + '"' + ": " + str(item))
			if regular_object_strings:
						dict_string += _format_to_lines(regular_object_strings)
						regular_object_strings = []
			
			dict_string = dict_string.indent("   ")
			return_string += dict_string
	return_string += "\n" + "--".rpad(max_line_length, "-")

	return return_string

static func _format_to_lines(input_strings: Array[String], max_line_length=50, border_string=", ") -> String:
	var new_lines = "\n"

	var line_length = 0

	for line in input_strings:
		if line.length() + line_length + border_string.length() > max_line_length:
			if new_lines.ends_with(border_string):
				new_lines = new_lines.substr(0, new_lines.length() - border_string.length())
			# create new line
			new_lines += "\n" + line + border_string
			line_length = line.length() + border_string.length()
		else:
			new_lines += line + border_string
	return new_lines


## splits up a path and returns the last n parts
static func get_last_path_parts(path: String, number_parts: int, is_reverse=false):
	var path_parts = []
	for part in path.split("/"):
		path_parts.append_array(part.split("\\"))
	path_parts.reverse()
	path_parts = path_parts.slice(0, number_parts)
	path_parts.reverse()
	return path_parts

## turns a custom object into a dictionary for json serialization
## adds class_name key if one was defined and script_name key to distinguish the dictionaries
static func object_to_dict(obj: Object):
	var obj_properties: Array[Dictionary] = obj.get_property_list()

	var return_dict: Dictionary = {}

	var class_name_line = obj.get_script().get_global_name()
	
	if class_name_line:
		return_dict["class_name"] = class_name_line

	
	return_dict["script_name"] = get_object_script_name(obj)
	for property in obj_properties:
		# TODO: implement saving of sub_objects
		var prop_name = property["name"]
		var prop_value = obj.get(prop_name) 
		if prop_value:
			return_dict[prop_name] = prop_value 
	return return_dict

static func get_object_script_name(obj):
	var file_name = get_last_path_parts(obj.get_script().resource_path, 1).pop_back()
	return file_name.substr(0, file_name.length() - 3)

## returns the file ending of a path
static func get_file_ending(path: String):
	var file_name = get_last_path_parts(path, 1).pop_back()
	if "." in file_name:
		return file_name.substr(file_name.rfind(".") + 1)
	else:
		return ""


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
	
	return filePathArray
