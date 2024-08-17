@tool
extends InputManager
## This class Handles ArrayInputs as InputManager
## Uses array_element_input as InputNodes for the UI of the Inputs.
## InputManager Objects are stored in inputManagers array and sorted when UI nodes are moved

var arrayElementScene = preload("res://addons/object_creator/Scenes/Variable Input Scenes/array_element_input.tscn")

var defaultInput = preload("res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn")
var boolInput = preload("res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn")
var arrayInput
var vectorInput = preload("res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn")

var addElementButton: Button
var elementTypeButton: DataTypeOptionButton
var isMinimized = false
var addElementSection: HBoxContainer

var selectedType: Variant.Type = Variant.Type.TYPE_NIL
var inputManagers: Array
const VECTOR_TYPES = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]

func set_up_nodes():
	addElementSection = get_node("AddElementSection")
	typeLabel = addElementSection.get_node("PropertyType")
	nameLabel = addElementSection.get_node("PropertyName")
	inputWarning = get_node("Warning")
	addElementButton = addElementSection.get_node("AddElementButton")
	elementTypeButton = addElementSection.get_node("ElementTypeButton")
	

func initialize_input(propertyDict: Dictionary):
	property = propertyDict
	set_up_nodes()
	nameLabel.text = propertyDict["name"]

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
	
	add_child(newInputNode) # add ArrayElementInput as new child
	var actual_position = get_children().size() - 2 
	move_child(newInputNode, actual_position) # so the warning is always at the bottom
	# Sets the child position so we can move it with the arrow up and down buttons
	newInputNode.position_child = actual_position
	newInputNode.initialize_input(newInputManager)
	
	# connect remove and move buttons
	newInputNode.connect("move_node", Callable(self, "_on_move_node"))
	newInputNode.connect("remove_node", Callable(self, "_on_remove_node"))


func _on_type_button_selected(index):
	selectedType = elementTypeButton.return_type_by_index(index)

func attempt_submit() -> Variant:
	var missingInputNodes = []
	var returnArray = []
	for inputManager: InputManager in inputManagers:
		var inputValue = inputManager.attempt_submit()
		if inputValue != null:
			inputManager.hide_input_warning()
			returnArray.append(inputValue)
		else:
			missingInputNodes.append(inputManager)
	
	if not missingInputNodes.is_empty():
		for inputManager: InputManager in missingInputNodes:
			inputManager.show_input_warning()
		return null
	
	return returnArray

## Minimizes Arrays for better UX
func _on_minimize_pressed():
	for node: Node in get_children():
		if node.name != "AddElementSection" and node.name != "Warning":
			node.visible = isMinimized
	if isMinimized:
		isMinimized = false
	else:
		isMinimized = true
	pass 

## Moves an InputNode in the Array UI
## Is called by a signal when the remove Button is pressed in ArrayElementInput
## Since the Array UI represents the Array Position later on, this also sorts the Input Managers
func _on_move_node(node: ArrayElementInput, new_position: int):
	
	if new_position >= get_children().size() - 1 or new_position < 1:
		return # elements shouldn't be under the warning or over the first element
	else:
		move_child(node, new_position)
		node.position_child = new_position
		# set all child positions correctly
		var i = 0;
		for child in get_children():
			if child.is_class("VBoxContainer"):
				if child.position_child != i:
					child.position_child = i
					
			i += 1
		
		inputManagers.sort_custom(func(a, b): return a.array_position < b.array_position)
		print(inputManagers)

## Removes InputNode from the Array UI
func _on_remove_node(node: ArrayElementInput):
	inputManagers.remove_at(inputManagers.find(node.input))
	remove_child(node)
