@tool
class_name InputManager
extends VBoxContainer
## Parent Class of all Input Scenes
## Should in essence be regarded as an abstract class

var property: Dictionary
var inputType: Variant.Type
var nameLabel
var typeLabel
var inputNode
var inputWarning
var array_position: int # position if inputmanager is within an array

func initialize_input(propertyDict: Dictionary):
	property = propertyDict


func attempt_submit() -> Variant:
	var returnValue
	return returnValue

## takes an input that fits the input type and checks whether it fits the range criteria
## not implemented yet
func check_input_range(input: Variant) -> bool:
	if typeof(input) != inputType:
		return false
	# TODO: add functionality that makes it possible to set custom ranges
	match typeof(input):
		TYPE_BOOL:
			return true
		TYPE_INT:
			return true
		TYPE_FLOAT:
			return true
		TYPE_STRING:
			return true
		TYPE_VECTOR2:
			pass
		TYPE_NODE_PATH:
			pass
		TYPE_CALLABLE:
			pass
		TYPE_DICTIONARY:
			pass
		TYPE_ARRAY:
			pass
	
	return true

func return_type_string(type: Variant.Type) -> String:
	match type:
		TYPE_BOOL:
			return "bool"
		TYPE_INT:
			return "int"
		TYPE_FLOAT:
			return "float"
		TYPE_STRING:
			return "String"
		TYPE_VECTOR2:
			return "Vector2"
		TYPE_VECTOR2I:
			return "Vector2i"
		TYPE_VECTOR3:
			return "Vector3"
		TYPE_VECTOR3I:
			return "Vector3i"
		TYPE_VECTOR4:
			return "Vector4"
		TYPE_VECTOR4I:
			return "Vector4i"
		TYPE_NODE_PATH:
			return "Node Path"
		TYPE_CALLABLE:
			return "callable"
		TYPE_DICTIONARY:
			return "Dictionary"
		TYPE_ARRAY:
			return "Array"
		_:
			return "unsupported"

## sets the labels and vars for a given property, is used in non array inputs
func set_property_information(property: Dictionary):
	self.property = property
	nameLabel.text = property["name"]
	inputType = property["type"]

func show_input_warning():
	inputWarning.visible = true
	pass

func hide_input_warning():
	inputWarning.visible = false
