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

#region config_variables
## range describes number range for int/float and size range for string/array/dictionary
var config
var range_max: int
var range_min: int
var accept_empty: bool
var change_empty_default: bool
var disable_editing: bool
var default_value
#endregion

## set up function that is called by the CreateObject class [br]
## is the first function that is called, before the ready func
func initialize_input(property_dict: Dictionary):
	property = property_dict

func attempt_submit(mute_warnings=false) -> Variant:
	var return_value
	return return_value

## Parent Virtual Function for all input Managers to bring their input into a save format
## So the CreateObject class can save it
func submit_status_dict() -> Dictionary:
	# TODO: I should consider moving the dict creation in this parent function and only changing the value in the sub_functions
	return {}

func set_up_config_rules(config):
	self.config = Helper.flatten_sub_dicts(config)
	var config_order = ["CLASS_GENERAL_CONFIG", return_type_string(input_type, false)]
	config_order = (config_order + [property["name"]]) if property else config_order
	self.apply_config_rules(config_order)

## virtual function which each sub_class handles differently to apply the json config
func apply_config_rules(config_order: Array):
	for config_key in config_order:
		if config_key in config.keys():
			var dict = config[config_key]
			Helper.apply_dict_values_object(self, dict)

## takes an input that fits the input type and checks whether it fits the range criteria
## not implemented yet
func check_range_invalid(input: Variant) -> bool:
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

func return_type_string(type: Variant.Type, is_default = true) -> String:
	match type:
		TYPE_BOOL:
			return "bool" if is_default else "TYPE_BOOL"
		TYPE_INT:
			return "int" if is_default else "TYPE_INT"
		TYPE_FLOAT:
			return "float" if is_default else "TYPE_FLOAT"
		TYPE_STRING:
			return "String" if is_default else "TYPE_STRING"
		TYPE_VECTOR2:
			return "Vector2" if is_default else "TYPE_VECTOR2"
		TYPE_VECTOR2I:
			return "Vector2i" if is_default else "TYPE_VECTOR2I"
		TYPE_VECTOR3:
			return "Vector3" if is_default else "TYPE_VECTOR3"
		TYPE_VECTOR3I:
			return "Vector3i" if is_default else "TYPE_VECTOR3I"
		TYPE_VECTOR4:
			return "Vector4" if is_default else "TYPE_VECTOR4"
		TYPE_VECTOR4I:
			return "Vector4i" if is_default else "TYPE_VECTOR4I"
		TYPE_NODE_PATH:
			return "Node Path" if is_default else "TYPE_NODE_PATH"
		TYPE_CALLABLE:
			return "callable" if is_default else "TYPE_CALLABLE"
		TYPE_DICTIONARY:
			return "Dictionary" if is_default else "TYPE_DICTIONARY"
		TYPE_ARRAY:
			return "Array" if is_default else "TYPE_ARRAY"
		TYPE_OBJECT:
			return "Object" if is_default else "TYPE_OBJECT"
		_:
			return "unsupported"

## sets the labels and vars for a given property, is used in non array inputs
func set_property_information(property: Dictionary):
	self.property = property
	name_label.text = property["name"]
	input_type = property["type"]

func show_input_warning(mute_warnings=false):
	if mute_warnings:
		return
	input_warning.visible = true

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
