@tool
class_name MultiElementInput
extends InputManager


const SUPPORTED_TYPES = ["String", "int", "float", "bool", "Array", "Dictionary","Vector2", "Vector3", "Vector4", "Vector2i", "Vector3i", "Vector4i"]
const VECTOR_TYPES = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]

var element_container_scene = preload("res://addons/object_creator/Scenes/Variable Input Scenes/multi_element_container.tscn")

var add_element_button: Button
var element_type_button: DataTypeOptionButton
var is_minimized = false
var add_element_section: HBoxContainer

var selected_type: Variant.Type = Variant.Type.TYPE_NIL
var input_managers: Array

var input_scenes = {
	"default": preload("res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"),
	"bool": preload("res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn"),
	"vector": preload("res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn"),
	"array": load("res://addons/object_creator/Scenes/Variable Input Scenes/array_input.tscn"),
	"dictionary": load("res://addons/object_creator/Scenes/Variable Input Scenes/dictionary_input.tscn"),
	"object": preload("res://addons/object_creator/Scenes/Variable Input Scenes/object_input.tscn")
}
## holds the sub_config which describes how the items of this dict/arr behave
var sub_config: Dictionary

## gets called first and is used to initialize values
func initialize_input(property_dict: Dictionary):
	if property_dict:
		property = property_dict
		set_up_nodes()
		name_label.text = property_dict["name"]
		input_type = property_dict["type"]

func set_up_nodes():
	add_element_section = get_node("AddElementSection")
	type_label = add_element_section.get_node("PropertyType")
	name_label = add_element_section.get_node("PropertyName")
	input_warning = get_node("Warning")
	add_element_button = add_element_section.get_node("AddElementButton")
	element_type_button = add_element_section.get_node("ElementTypeButton")
	
	# connect buttons
	add_element_button.connect("pressed", Callable(self, "_on_add_element_button_pressed"))
	element_type_button.connect("item_selected", Callable(self, "_on_type_button_selected"))
	get_node("AddElementSection/MinimizeButton").connect("pressed", Callable(self, "_on_minimize_pressed"))
	
	for type in SUPPORTED_TYPES:
		element_type_button.add_item(type)
	
	if property:
		check_typed() # must be called after the items are added to the select button
	
	# select first type per default
	_on_type_button_selected(0)

func check_typed():
	pass

## virtual function for dict/arr inputs to overide
func add_element(element_type: Variant.Type, def_input=null):
	pass

func create_scene_by_type(type: Variant.Type) -> Dictionary:
	var return_dict = {}
	var is_vector = false
	var new_scene: PackedScene

	match type:
		TYPE_NIL:
			return return_dict
		TYPE_INT:
			new_scene = input_scenes["default"]
		TYPE_FLOAT:
			new_scene = input_scenes["default"]
		TYPE_STRING:
			new_scene = input_scenes["default"]
		TYPE_BOOL:
			new_scene = input_scenes["bool"]
		TYPE_ARRAY:
			new_scene = input_scenes["array"]
		TYPE_DICTIONARY:
			new_scene = input_scenes["dictionary"]
		_:
			if VECTOR_TYPES.has(type):
				new_scene = input_scenes["vector"]
				is_vector = true
	var new_input_node: MultiElementContainer =  element_container_scene.instantiate()
	var new_input_manager = new_scene.instantiate()
	input_managers.append(new_input_manager)
	new_input_manager.input_type = type
	
	add_child(new_input_node) # add MultiElementContainer as new child

	var actual_position = get_children().size() - 2 
	move_child(new_input_node, actual_position) # so the warning is always at the bottom
	# Sets the child position so we can move it with the arrow up and down buttons
	new_input_node.position_child = actual_position
	new_input_node.initialize_input(new_input_manager)
	new_input_manager.initialize_input({})

	new_input_node.connect("remove_node", Callable(self, "_on_remove_node"))

	new_input_manager.set_up_config_rules(config["ROOT"])
	print(sub_config)
	if sub_config:
		new_input_manager.apply_config_rules([sub_config])
	
	return_dict = {
		"is_vector": is_vector,
		"input_node": new_input_node,
		"input_manager": new_input_manager
		}
	return return_dict

## disables certain types so the select button can't choose them anymore
## [param include_types_only] makes it so only the values in types are enabled and all others are disabled
func disable_select_type_button(types: Array, include_types_only = false, is_remove = false):
	var remove_items = []
	for i in element_type_button.item_count:
		var should_be_disabled = element_type_button.get_item_text(i) in types
		should_be_disabled = should_be_disabled if not include_types_only else not should_be_disabled
		if is_remove and should_be_disabled:
			remove_items.append(i)
		else:
			element_type_button.set_item_disabled(i, should_be_disabled)
	
	if remove_items:
		remove_items.sort()
		remove_items.reverse()
		for index in remove_items:
			element_type_button.remove_item(index)
			
	# now select a not disabled button
	for i in element_type_button.item_count:
		if element_type_button.is_item_disabled(i) == false:
			element_type_button.select(i)
			element_type_button.emit_signal("item_selected", i)
			break

func apply_config_rules(configs_ordered: Array):
	# TODO: fix the remove button and maybe add config var that makes only the default elements not editable
	var last_config = configs_ordered.back()
	print(last_config)
	sub_config = last_config["SUB_ARRAY_CONFIG"] if "SUB_ARRAY_CONFIG" in last_config.keys() else {}
	super(configs_ordered)

func set_input_disabled(is_disabled: bool):
	add_element_button.disabled = is_disabled
	for input: InputManager in input_managers:
		input.set_input_disabled(is_disabled)

#region signal_functions
func _on_type_button_selected(index):
	selected_type = element_type_button.return_type_by_index(index)

## Minimizes Arrays for better UX
func _on_minimize_pressed():
	for node: Node in get_children():
		if node.name != "AddElementSection" and node.name != "Warning":
			node.visible = is_minimized
	if is_minimized:
		is_minimized = false
	else:
		is_minimized = true

func _on_add_element_button_pressed() -> void:
	add_element(selected_type)
#endregion
