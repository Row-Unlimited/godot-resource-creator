@tool
class_name PluginConfig
extends Resource

@export var used_exportPaths: Array
@export var isIntegrated: bool
@export var integrated_classPaths: Array[String]
@export var classObjects: Array
@export var set_exportPath: String
@export var disable_navigator: bool = false
@export var ignored_directories: Array[String]
@export var accept_empty_inputs : bool = true
## when accept_empty_inputs is true and an input is submitted empty this will submit the null value
## (0 for int, "" for String etc. instead of null)
@export var use_null_values_for_empty: bool = false


#region subobject settings
## default puts sub_objects into the same folder as the parent_object
## defines if a new folder for subobjects should be created
@export var is_folder_hierarchical: bool = false
#endregion

## config users can create to define precisely how they want the creation to be handled [br]
## can be used to:[br] - define default property values [br] - exclude classes as sub_classes [br]
### - lock properties
@export var class_configs: Array



func contains(object_wrapper: ObjectWrapper) -> ObjectWrapper:
	for classObject: ObjectWrapper in classObjects:
		if classObject.className == object_wrapper.className:
			return classObject
	return null

func update_user_path_information(path: String):
	for pathTuple: PathTuple in used_exportPaths:
		if pathTuple.path == path:
			pathTuple.times_used += 1
			return
	var new_tuple = PathTuple.new(path)
	used_exportPaths.append(new_tuple)

func update_user_class_information(classObjectNew: ObjectWrapper):
	for object_wrapper: ObjectWrapper in classObjects:
		if object_wrapper.path == classObjectNew.path:
			object_wrapper.times_used += 1
			return
	classObjects.append(classObjectNew)

func sort_arrays():
	used_exportPaths.sort_custom(return_higher_path)
	classObjects.sort_custom(return_higher_class)

func return_higher_path(a: PathTuple, b: PathTuple):
	if a.times_used >= b.times_used:
		return true
	return false

func return_higher_class(a: ObjectWrapper, b: ObjectWrapper):
	if a.times_used >= b.times_used:
		return true
	return false

func load_class_configs():
	class_configs = Helper.search_filetypes_in_directory(".json", "res://addons/object_creator/ClassConfigs")
	class_configs = class_configs.map(func(x): return JSON.new().parse_string(FileAccess.get_file_as_string(x)))

func get_config_by_path(path: String):
	load_class_configs()
	var config = class_configs.filter(func(x): return x["resource_path"] == path).pop_back()
	return config if config else null
