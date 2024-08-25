@tool
class_name InputManager
extends VBoxContainer
## Parent Class of all Input Scenes
## Should in essence be regarded as an abstract class

var property: Dictionary
var input_type: Variant.Type
var name_label
var type_label
var input_node
var input_warning
var array_position: int # position if inputmanager is within an array
var accept_empty_inputs : bool

func initialize_input(property_dict: Dictionary):
	property = property_dict


func attempt_submit() -> Variant:
	var return_value
	return return_value

## takes an input that fits the input type and checks whether it fits the range criteria
## not implemented yet
func check_input_range(input: Variant) -> bool:
	if typeof(input) != input_type:
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
	name_label.text = property["name"]
	input_type = property["type"]

func show_input_warning():
	input_warning.visible = true
	pass

func return_empty_by_type():
	match input_type:
		TYPE_INT:
			return 0
		TYPE_FLOAT:
			return 0.
		TYPE_STRING:
			return ""

func hide_input_warning():
	input_warning.visible = false

## virtual function that should be used so each input type can receive input when created
## primarily useful when we're dealing with editing objects instead of creating them
func receive_input(input):
	pass
