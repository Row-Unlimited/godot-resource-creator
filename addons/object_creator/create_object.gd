@tool
extends Control
## UI Window which creates custom input boxes for each property of the chosen class
## Checks if Inputs are correct by calling attempt_submit method in the InputManager objects

var testInput = preload("res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn")
var breakLine = preload("res://addons/object_creator/Scenes/break_line.tscn")
var inputRootNode: VBoxContainer
var submitButton: Button
var inputNodes: Array
var classObject: ClassObject
var propertyList: Array

var skippedProperties =["resource_local_to_scene", "resource_path", "resource_name"]

signal object_created(object)

func initialize_UI(cObject: ClassObject):
	classObject = cObject
	propertyList = load(classObject.path).new().get_property_list()
	inputRootNode = get_node("ScrollContainer/VBoxContainer")
	submitButton = get_node("SubmitBox/CreateObject")
	submitButton.connect("pressed", Callable(self, "on_submit_pressed"))
	
	for property: Dictionary in propertyList:
		var newInputPath = determine_input_type(property)
		if newInputPath != "" and not skippedProperties.has(property["name"]):
			var newInput = load(newInputPath).instantiate()
			inputRootNode.add_child(breakLine.instantiate())
			inputRootNode.add_child(newInput)
			newInput.initialize_input(property)
			inputNodes.append(newInput)

func determine_input_type(property: Dictionary) -> String:
	var vectorTypes = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]
	var sceneString: String
	match property["type"]:
		TYPE_BOOL:
			sceneString = "res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn"
		TYPE_INT:
			sceneString = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_FLOAT:
			sceneString = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_STRING:
			sceneString = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_NODE_PATH:
			sceneString = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_CALLABLE:
			sceneString = "res://addons/object_creator/Scenes/Variable Input Scenes/callable_input.tscn"
		TYPE_DICTIONARY:
			sceneString = "res://addons/object_creator/Scenes/Variable Input Scenes/dictionary_input.tscn"
		TYPE_ARRAY:
			sceneString = "res://addons/object_creator/Scenes/Variable Input Scenes/array_input.tscn"
		_:
			if vectorTypes.has(property["type"]):
				sceneString = "res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn"
			else:
				sceneString = ""
	return sceneString


func on_submit_pressed():
	var tempObject: Object = load(classObject.path).new()
	var missingInputNodes: Array
	
	for inputNode: InputManager in inputNodes:
		var inputValue = inputNode.attempt_submit()
		if inputValue != null:
			tempObject.set(inputNode.property["name"], inputValue)
			inputNode.hide_input_warning()
		else:
			missingInputNodes.append(inputNode)
	
	if missingInputNodes.is_empty():
		emit_signal("object_created", tempObject)
	else:
		for inputManager: InputManager in missingInputNodes:
			inputManager.show_input_warning()
		return
