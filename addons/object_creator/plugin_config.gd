@tool
class_name PluginConfig
extends Resource

@export var usedExportPaths: Array
@export var isIntegrated: bool
@export var integratedClassPaths: Array
@export var classObjects: Array
@export var setExportPath: String
@export var disableNavigator: bool = false
@export var ignoredDirectories: Array


func contains(cObject: ClassObject) -> ClassObject:
	for classObject: ClassObject in classObjects:
		if classObject.className == cObject.className:
			return classObject
	return null

func update_user_path_information(path: String):
	for pathTuple: PathTuple in usedExportPaths:
		if pathTuple.path == path:
			pathTuple.timesUsed += 1
			return
	var newTuple = PathTuple.new(path)
	usedExportPaths.append(newTuple)

func update_user_class_information(classObjectNew: ClassObject):
	for cObject: ClassObject in classObjects:
		if cObject.path == classObjectNew.path:
			cObject.timesUsed += 1
			return
	classObjects.append(classObjectNew)

func sort_arrays():
	usedExportPaths.sort_custom(return_higher_path)
	classObjects.sort_custom(return_higher_class)

func return_higher_path(a: PathTuple, b: PathTuple):
	if a.timesUsed >= b.timesUsed:
		return true
	return false

func return_higher_class(a: ClassObject, b: ClassObject):
	if a.timesUsed >= b.timesUsed:
		return true
	return false
