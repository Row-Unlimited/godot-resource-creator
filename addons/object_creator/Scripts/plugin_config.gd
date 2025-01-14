@tool
class_name PluginConfig
extends Resource

var used_exportPaths: Array
var object_wrappers: Array

@export var set_exportPath: String
@export var ignored_directories: Array[String]
@export var accept_empty_inputs : bool = true
@export var error_color: Color
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
var class_configs: Array


func load_class_configs():
	class_configs = DirHelper.search_filetypes_in_directory(".json", "res://addons/object_creator/ClassConfigs")
	class_configs = class_configs.map(func(x): return JSON.new().parse_string(FileAccess.get_file_as_string(x)))

func get_config_by_path(path: String):
	load_class_configs()
	var config = class_configs.filter(func(x): return x["resource_path"] == path).pop_back()
	return config if config else null
