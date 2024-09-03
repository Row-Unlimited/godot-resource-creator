@tool
class_name DictionaryInput
extends InputManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

const SUPPORTED_TYPES = ["String", "int", "float", "bool", "Array", "Dictionary","Vector2", "Vector3", "Vector4", "Vector2i", "Vector3i", "Vector4i"]

var array_element_scene = preload("res://addons/object_creator/Scenes/Variable Input Scenes/array_element_input.tscn")

var default_input = preload("res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn")
var bool_input = preload("res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn")
var array_input
var vector_input = preload("res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn")

var add_element_button: Button
var element_type_button: DataTypeOptionButton
var is_minimized = false
var add_element_section: HBoxContainer

var selected_type: Variant.Type = Variant.Type.TYPE_NIL
var input_managers: Array
const VECTOR_TYPES = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]


## gets called first and is used to initialize values
func initialize_input(property_dict: Dictionary):
	property = property_dict
	set_up_nodes()
	name_label.text = property_dict["name"]

func set_up_nodes():
	add_element_section = get_node("AddElementSection")
	type_label = add_element_section.get_node("PropertyType")
	name_label = add_element_section.get_node("PropertyName")
	input_warning = get_node("Warning")
	add_element_button = add_element_section.get_node("AddElementButton")
	element_type_button = add_element_section.get_node("ElementTypeButton")
	for type in SUPPORTED_TYPES:
		element_type_button.add_item(type)
	check_typed_dict()

## will be added once typed_dicts are added
func check_typed_dict():
	pass

func add_element(key_type: Variant.Type, value_type: Variant.Type, def_input = null):
	
	pass
