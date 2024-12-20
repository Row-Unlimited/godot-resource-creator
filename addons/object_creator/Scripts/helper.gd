@tool
class_name Helper
extends Object

static func equal(a, b):
	return typeof(a) == typeof(b) and a == b

static func array_to_string(arr: Array) -> String:
	var return_string = ""
	for string in arr:
		return_string += string
	return return_string

static func check_string_contains_array(stringArray: Array, checkString: String):
	for string: String in stringArray:
		if checkString.contains(string):
			return true
	return false

## only works for now if class has a constructor with no or only optional parameters
static func duplicate_object(obj: Object):
	var new_obj = obj.get_script().new()
	var properties = obj.get_property_list()

	for prop_dict in properties:
		var prop_name = prop_dict["name"]
		var prop_value = obj.get(prop_name)
		new_obj.set(prop_name, prop_value)
	
	return new_obj

static func intersect_arrays(arr1, arr2):
	var arr2_dict = {}
	for v in arr2:
		arr2_dict[v] = true

	var in_both_arrays = []
	for v in arr1:
		if arr2_dict.get(v, false):
			in_both_arrays.append(v)
	return in_both_arrays

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
static func custom_to_vector(vec_representation, as_int_vector = false):
	var vec_array = []
	# make the vector representation into an array
	match typeof(vec_representation):
		TYPE_STRING:
			var regex = RegEx.new()
			regex.compile(r"(?<number>(?:[1-9]+[0-9]*|0)\.*(?:[0-9]*))[,\)]")
			if as_int_vector:
				regex.compile(r"(?<=[\(\s])(?<number>(?:[1-9][0-9]*|0))(?=[,\)])")
			var numbers = []
			for result in regex.search_all(vec_representation):
				numbers.append(result.get_string("number").to_float() if not as_int_vector else result.get_string("number").to_int())
			vec_array = numbers
		TYPE_ARRAY:
			vec_representation = vec_representation.map(map_string_to_int_float)
			for value in vec_representation:
				if not typeof(value) in [TYPE_INT, TYPE_FLOAT]:
					assert(false, "ERROR: NON INT/FLOAT TYPE VALUE IN VEC REPRESENTATION ARRAY")
				elif as_int_vector and not typeof(value) in [TYPE_INT]:
					assert(false, "ERROR: NON INT TYPE VALUE IN VEC REPRESENTATION ARRAY")
			vec_array = vec_representation
	
	match vec_array.size():
				2:
					return Vector2(vec_array[0], vec_array[1]) if not as_int_vector else Vector2i(vec_array[0], vec_array[1])
				3:
					return Vector3(vec_array[0], vec_array[1], vec_array[2]) if not as_int_vector else Vector3i(vec_array[0], vec_array[1], vec_array[2])
				4:
					return Vector4(vec_array[0], vec_array[1], vec_array[2], vec_array[3]) if not as_int_vector else Vector4i(vec_array[0], vec_array[1], vec_array[2], vec_array[3])
				_:
					return null

static func map_string_to_int_float(value):
	if typeof(value) == TYPE_STRING:
		if value.is_valid_int:
			return value.to_int()
		elif value.is_valid_float:
			return value.to_float()
	else:
		return value

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

static func apply_dict_values_object(obj: Object, value_dict: Dictionary):
	var keys = value_dict.keys()
	var prop_list = obj.get_property_list()
	var prop_names = prop_list.map(func(x:Dictionary): return x["name"])
	
	keys = intersect_arrays(keys, prop_names)

	for key in keys:
		obj.set(key, value_dict[key])

## puts all sub dicts of a dictionary in one dictionary side by side (if some dicts have the same name this does not work) [br]
## with [param search_keys] you can change the behavior so the return dictionary only has the ROOT and all dicts that had one of the specified search keys
static func flatten_sub_dicts(dict: Dictionary, search_keys = []):
	var return_dict = {"ROOT": dict}
	for key in dict.keys():
		var value = dict[key]
		if typeof(value) == TYPE_DICTIONARY:
			if not search_keys or (key in search_keys):
				return_dict[key] = value
			return_dict.merge(flatten_sub_dicts(value, search_keys))
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
	
	filePathArray = filePathArray.map(func(x:String): return x.replace("res:///", "res://"))
	
	return filePathArray

static func file_name_to_class_name(file_name: String):
	var name_parts = Array(file_name.split("_"))
	name_parts = name_parts.map(func(x): x[0] = x[0].to_upper(); return x)
	name_parts = name_parts.map(func(x): return x if not "." in x else x.split(".")[0])
	return array_to_string(name_parts)
