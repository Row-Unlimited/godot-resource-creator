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
@export var is_main_dock : bool = false
@export var accept_empty_inputs : bool = true


#region subobject settings
## default puts sub_objects into the same folder as the parent_object
## defines if a new folder for subobjects should be created
@export var is_folder_hierarchical: bool = false
#endregion

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
