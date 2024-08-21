@tool
class_name PluginConfig
extends Resource

@export var used_exportPaths: Array
@export var isIntegrated: bool
@export var integrated_classPaths: Array
@export var classObjects: Array
@export var set_exportPath: String
@export var disable_navigator: bool = false
@export var ignored_directories: Array
@export var is_main_dock : bool = false


func contains(cObject: ClassObject) -> ClassObject:
	for classObject: ClassObject in classObjects:
		if classObject.className == cObject.className:
			return classObject
	return null

func update_user_path_information(path: String):
	for pathTuple: PathTuple in used_exportPaths:
		if pathTuple.path == path:
			pathTuple.times_used += 1
			return
	var new_tuple = PathTuple.new(path)
	used_exportPaths.append(new_tuple)

func update_user_class_information(classObjectNew: ClassObject):
	for cObject: ClassObject in classObjects:
		if cObject.path == classObjectNew.path:
			cObject.times_used += 1
			return
	classObjects.append(classObjectNew)

func sort_arrays():
	used_exportPaths.sort_custom(return_higher_path)
	classObjects.sort_custom(return_higher_class)

func return_higher_path(a: PathTuple, b: PathTuple):
	if a.times_used >= b.times_used:
		return true
	return false

func return_higher_class(a: ClassObject, b: ClassObject):
	if a.times_used >= b.times_used:
		return true
	return false
