@tool
class_name PluginConfig
extends Resource

@export var usedExportPaths: Array
@export var usedClassPaths: Array
@export var isIntegrated: bool
@export var integratedClassPaths: Array
@export var classObjects: Array
@export var setExportPath: String
@export var disableNavigator: bool = false


func contains(cObject: ClassObject) -> ClassObject:
	for classObject in classObjects:
		if classObject.className == cObject.className:
			return classObject
	return null
