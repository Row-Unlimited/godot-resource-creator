@tool
class_name UserInformation
extends Resource

@export var defaultExportPath = ""
@export var usedExportPaths: Array
@export var usedClassPaths: Array
@export var isIntegrated: bool
@export var integratedClassPaths: Array
@export var classObjects: Array

func contains(cObject: ClassObject) -> ClassObject:
	for classObject in classObjects:
		if classObject.className == cObject.className:
			return classObject
	return null
