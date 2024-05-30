@tool
extends InputManager

var arrayElementScene = preload("res://addons/object_creator/Scenes/Variable Input Scenes/array_element_input.tscn")

var defaultInput = preload("res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn")
var boolInput = preload("res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn")
var arrayInput
var vectorInput = preload("res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn")
var breakLine = preload("res://addons/object_creator/Scenes/break_line_array.tscn")

var addElementButton: Button
var elementTypeButton: DataTypeOptionButton

var selectedType: Variant.Type = Variant.Type.TYPE_NIL
var inputManagers: Array
const VECTOR_TYPES = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]

func set_up_nodes():
	typeLabel = get_node("InputContainer/PropertyType")
	nameLabel = get_node("InputContainer/PropertyName")
	inputNode = get_node("InputContainer/Input")
	inputWarning = get_node("WarningContainer/WrongInputWarning")
	addElementButton = get_node("AddElementSection/AddElementButton")
	elementTypeButton = get_node("AddElementSection/ElementTypeButton")
	typeLabel.text = return_type_string(inputType)

func initialize_input(propertyDict: Dictionary):
	property = propertyDict
	set_up_nodes()

func _on_add_element_pressed():
	var isVector = false
	var newScene: PackedScene
	match selectedType:
		TYPE_NIL:
			return
		TYPE_INT:
			newScene = defaultInput
		TYPE_FLOAT:
			newScene = defaultInput
		TYPE_STRING:
			newScene = defaultInput
		TYPE_BOOL:
			newScene = boolInput
		TYPE_ARRAY:
			newScene = arrayInput
		_:
			if VECTOR_TYPES.has(selectedType):
				newScene = vectorInput
				isVector = true
	
	var newInputNode: ArrayElementInput =  arrayElementScene.instantiate()
	var newInputManager = newScene.instantiate()
	inputManagers.append(newInputManager)
	newInputManager.inputType = selectedType
	
	add_child(breakLine.instantiate())
	add_child(newInputNode)
	
	newInputNode.initialize_input(newInputManager)
	newInputManager.set_up_nodes()


func _on_type_button_selected(index):
	selectedType = elementTypeButton.return_type_by_index(index)

func attempt_submit() -> Variant:
	var missingInputNodes: Array
	var returnArray = []
	for inputManager: InputManager in inputManagers:
		var inputValue = inputNode.attempt_submit()
		if inputValue != null:
			inputNode.hide_input_warning()
			returnArray.append(inputValue)
		else:
			missingInputNodes.append(inputNode)
	
	if missingInputNodes.is_empty():
		for inputManager: InputManager in missingInputNodes:
			inputManager.show_input_warning()
		return null
	
	return returnArray
