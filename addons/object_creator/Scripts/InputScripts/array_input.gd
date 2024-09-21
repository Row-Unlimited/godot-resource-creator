@tool
class_name ArrayInput
extends InputManager
## This class Handles Array_inputs as InputManager
## Uses multi_element_container as InputNodes for the UI of the Inputs.
## InputManager Objects are stored in input_managers array and sorted when UI nodes are moved

const SUPPORTED_TYPES = ["String", "int", "float", "bool", "Array", "Dictionary","Vector2", "Vector3", "Vector4", "Vector2i", "Vector3i", "Vector4i"]

var element_container_scene = preload("res://addons/object_creator/Scenes/Variable Input Scenes/multi_element_container.tscn")

## holds the scene paths to all the different InputManager scenes
var input_scenes = {
	"default": preload("res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"),
	"bool": preload("res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn"),
	"vector": preload("res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn"),
	"array": load("res://addons/object_creator/Scenes/Variable Input Scenes/array_input.tscn"),
	"dictionary": load("res://addons/object_creator/Scenes/Variable Input Scenes/dictionary_input.tscn"),
	"object": preload("res://addons/object_creator/Scenes/Variable Input Scenes/object_input.tscn")
}

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
	input_type = property_dict["type"]

func set_up_nodes():
	add_element_section = get_node("AddElementSection")
	type_label = add_element_section.get_node("PropertyType")
	name_label = add_element_section.get_node("PropertyName")
	input_warning = get_node("Warning")
	add_element_button = add_element_section.get_node("AddElementButton")
	element_type_button = add_element_section.get_node("ElementTypeButton")
	for type in SUPPORTED_TYPES:
		element_type_button.add_item(type)
	if property:
		check_typed_array()


func check_typed_array():
	var type_arr: String
	var hint_string : String = property["hint_string"]
	match property["hint"]:
		31:
			type_arr = hint_string
		23:
			var regex = RegEx.new()
			regex.compile("([1-9]{1}[0-9]{0,1}):")
			type_arr = regex.search(hint_string).get_string()
			type_arr = return_type_string(type_arr.to_int())
	if not type_arr:
		return
	if type_arr in SUPPORTED_TYPES:
		disable_select_type_button([type_arr], true)
	else:
		# TODO  find solution
		assert(false, "unsupported type in typed array")

## adds a new element to the input UI
## loads the correct InputManager and puts it into an MultiElementContainer		
func add_element(element_type: Variant.Type, def_input=null):
	var is_vector = false
	var new_scene: PackedScene
	match element_type:
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
			if VECTOR_TYPES.has(element_type):
				new_scene = input_scenes["vector"]
				is_vector = true
	var new_input_node: MultiElementContainer =  element_container_scene.instantiate()
	var new_input_manager = new_scene.instantiate()
	input_managers.append(new_input_manager)
	new_input_manager.input_type = element_type
	
	add_child(new_input_node) # add MultiElementContainer as new child
	var actual_position = get_children().size() - 2 
	move_child(new_input_node, actual_position) # so the warning is always at the bottom
	# Sets the child position so we can move it with the arrow up and down buttons
	new_input_node.position_child = actual_position
	new_input_node.initialize_input(new_input_manager)
	new_input_manager.initialize_input({})
	
	# connect remove and move buttons
	new_input_node.connect("move_node", Callable(self, "_on_move_node"))
	new_input_node.connect("remove_node", Callable(self, "_on_remove_node"))
	if def_input != null:
		new_input_manager.receive_input(def_input)

func _on_add_element_pressed():
	add_element(selected_type)


func _on_type_button_selected(index):
	selected_type = element_type_button.return_type_by_index(index)

func attempt_submit(mute_warnings=false) -> Variant:
	var missing_input_nodes = []
	var return_array = []
	for input_manager: InputManager in input_managers:
		var input_value = input_manager.attempt_submit()
		if input_value != null:
			input_manager.hide_input_warning()
			return_array.append(input_value)
		else:
			missing_input_nodes.append(input_manager)
	
	if not missing_input_nodes.is_empty():
		for input_manager: InputManager in missing_input_nodes:
			input_manager.show_input_warning(true)
		return null
	
	return return_array

func submit_status_dict():
	var value_list = [] # value of the status_dict; Contains all input nodes status_dicts
	for input_manager in input_managers:
		value_list.append(input_manager.submit_status_dict())
	
	# if it's a property it has a name, if it's a sub_element like in an array it is empty
	var property_name = property["name"] if property else "" 
	var status_dict = {"value" : value_list, "type" : input_type, "name" : property_name}
	return status_dict

## Minimizes Arrays for better UX
func _on_minimize_pressed():
	for node: Node in get_children():
		if node.name != "AddElementSection" and node.name != "Warning":
			node.visible = is_minimized
	if is_minimized:
		is_minimized = false
	else:
		is_minimized = true
	pass 

## Moves an InputNode in the Array UI
## Is called by a signal when the remove Button is pressed in MultiElementContainer
## Since the Array UI represents the Array Position later on, this also sorts the Input Managers
func _on_move_node(node: MultiElementContainer, new_position: int):
	
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
		
		input_managers.sort_custom(func(a, b): return a.array_position < b.array_position)

## Removes InputNode from the Array UI
func _on_remove_node(node: MultiElementContainer):
	input_managers.remove_at(input_managers.find(node.input))
	remove_child(node)

## takes an array and fills the input with input fields for each array element
func receive_input(input):
	for element in input:
		add_element(typeof(element), element)

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
