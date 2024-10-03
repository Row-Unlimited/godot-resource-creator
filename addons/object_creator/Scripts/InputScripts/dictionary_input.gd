@tool
class_name DictionaryInput
extends InputManager

const SUPPORTED_TYPES = ["String", "int", "float", "bool", "Array", "Dictionary","Vector2", "Vector3", "Vector4", "Vector2i", "Vector3i", "Vector4i"]

var element_container_scene = preload("res://addons/object_creator/Scenes/Variable Input Scenes/multi_element_container.tscn")

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
var element_containers : Array
const VECTOR_TYPES = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]

var input_scenes = {
	"default": preload("res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"),
	"bool": preload("res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn"),
	"vector": preload("res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn"),
	"array": load("res://addons/object_creator/Scenes/Variable Input Scenes/array_input.tscn"),
	"dictionary": load("res://addons/object_creator/Scenes/Variable Input Scenes/dictionary_input.tscn"),
	"object": preload("res://addons/object_creator/Scenes/Variable Input Scenes/object_input.tscn")
}

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
	get_node("AddElementSection/AddElementButton").connect("pressed", Callable(self, "_on_add_element_button_pressed"))
	get_node("AddElementSection/ElementTypeButton").connect("item_selected", Callable(self, "_on_type_button_selected"))

	for type in SUPPORTED_TYPES:
		element_type_button.add_item(type)
	check_typed_dict()

	# select first type per default
	_on_type_button_selected(0)

## will be added once typed_dicts are added
func check_typed_dict():
	pass

# TODO: add key_type: Variant.Type,
## Adds a new element to a Dictionary Input
func add_element( value_type: Variant.Type, def_key="", def_input = null):
	var is_vector = false
	var new_scene: PackedScene

	match value_type:
		TYPE_NIL:
			return
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
			if VECTOR_TYPES.has(value_type):
				new_scene = input_scenes["vector"]
				is_vector = true
	var new_input_node: MultiElementContainer =  element_container_scene.instantiate()
	var new_input_manager = new_scene.instantiate()
	input_managers.append(new_input_manager)
	new_input_manager.input_type = value_type
	
	add_child(new_input_node) # add MultiElementContainer as new child

	# dictionary values set up
	new_input_node.input_manager = new_input_manager # give the container the manager for the key exchange
	new_input_node.add_key_lineEdit() # Add lineEdit for entering keys
	new_input_node.remove_move_buttons()
	element_containers.append(new_input_node)


	var actual_position = get_children().size() - 2 
	move_child(new_input_node, actual_position) # so the warning is always at the bottom
	# Sets the child position so we can move it with the arrow up and down buttons
	new_input_node.position_child = actual_position
	new_input_node.initialize_input(new_input_manager)
	new_input_manager.initialize_input({})
	
	# connect remove button
	new_input_node.connect("remove_node", Callable(self, "_on_remove_node"))
	if def_key and not (def_key in get_all_keys()):
		if def_input:
			new_input_manager.receive_input(def_input)
		new_input_node.key_line_edit.text = def_key


func attempt_submit(mute_warnings=false) -> Variant:
	var missing_input_nodes = []
	var return_dict = {}

	for container in element_containers:
		var input_manager = container.input_manager 
		var new_key = container.key_line_edit.text
		if new_key:
			if new_key in return_dict.keys():
				# TODO add proper behavior
				missing_input_nodes.append(input_manager)
				assert(false, "ERROR: duplicate keys!")
			var value = input_manager.attempt_submit()
			if value:
				input_manager.hide_input_warning()
				return_dict[new_key] = value
		else:
			missing_input_nodes.append(input_manager)
	
	if not missing_input_nodes.is_empty():
		for input_manager: InputManager in missing_input_nodes:
			input_manager.show_input_warning(true)
		return null
	return return_dict

func submit_status_dict():
	var value_list = {} # value of the status_dict; Contains all input nodes status_dicts
	for container in element_containers:
		var input_dict = container.input_manager.submit_status_dict()
		var container_key = container.key_line_edit.text

		if not container_key or container_key in value_list.keys():
			# TODO: add correct behavior for reaction
			continue
		else:
			value_list[container_key] = input_dict
	
	# if it's a property it has a name, if it's a sub_element like in an array it is empty
	var property_name = property["name"] if property else "" 
	var status_dict = {"value" : value_list, "type" : input_type, "name" : property_name}
	return status_dict

func receive_input(input: Dictionary):
	for key in input.keys():
		var item_value = input[key]
		add_element(typeof(item_value), key, item_value)

## disables certain types so the select button can't choose them anymore
## [param include_types_only] makes it so only the values in types are enabled and all others are disabled
func disable_select_type_button(types: Array, include_types_only = false):
	for i in element_type_button.item_count:
		var should_be_disabled = element_type_button.get_item_text(i) in types
		should_be_disabled = should_be_disabled if not include_types_only else not should_be_disabled
		element_type_button.set_item_disabled(i, should_be_disabled)
	# now select a not disabled button
	for i in element_type_button.item_count:
		if element_type_button.is_item_disabled(i) == false:
			element_type_button.select(i)
			element_type_button.emit_signal("item_selected", i)
			break

func make_name_input(is_dict=false):
	# empty function since the MultiElementContainer needs to be set with that, which happens one step above
	pass

func get_all_keys() -> Array[String]:
	var key_list: Array[String] = [] as Array[String]
	
	for container in element_containers:
		var key_input = container.key_line_edit.text
		if key_input:
			key_list.append(key_input)

	return key_list

#region signal_methods
func _on_add_element_button_pressed() -> void:
	add_element(selected_type)


func _on_type_button_selected(index):
	selected_type = element_type_button.return_type_by_index(index)

## Minimizes Dictionary for better UX
func _on_minimize_pressed():
	for node: Node in get_children():
		if node.name != "AddElementSection" and node.name != "Warning":
			node.visible = is_minimized
	if is_minimized:
		is_minimized = false
	else:
		is_minimized = true

## Removes InputNode from the Dictionary UI
func _on_remove_node(node: MultiElementContainer):
	input_managers.remove_at(input_managers.find(node.input))
	remove_child(node)
#endregion