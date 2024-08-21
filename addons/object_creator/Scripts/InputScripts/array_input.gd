@tool
extends InputManager
## This class Handles Array_inputs as InputManager
## Uses array_element_input as InputNodes for the UI of the Inputs.
## InputManager Objects are stored in input_managers array and sorted when UI nodes are moved

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

func set_up_nodes():
	add_element_section = get_node("AddElementSection")
	type_label = add_element_section.get_node("PropertyType")
	name_label = add_element_section.get_node("PropertyName")
	input_warning = get_node("Warning")
	add_element_button = add_element_section.get_node("AddElementButton")
	element_type_button = add_element_section.get_node("ElementTypeButton")
	

func initialize_input(property_dict: Dictionary):
	property = property_dict
	set_up_nodes()
	name_label.text = property_dict["name"]

func add_element(element_type: Variant.Type, def_input=null):
	var is_vector = false
	var new_scene: PackedScene
	match selected_type:
		TYPE_NIL:
			return
		TYPE_INT:
			new_scene = default_input
		TYPE_FLOAT:
			new_scene = default_input
		TYPE_STRING:
			new_scene = default_input
		TYPE_BOOL:
			new_scene = bool_input
		TYPE_ARRAY:
			new_scene = array_input
		_:
			if VECTOR_TYPES.has(selected_type):
				new_scene = vector_input
				is_vector = true
	var new_input_node: ArrayElementInput =  array_element_scene.instantiate()
	var new_input_manager = new_scene.instantiate()
	input_managers.append(new_input_manager)
	new_input_manager.input_type = selected_type
	
	add_child(new_input_node) # add ArrayElementInput as new child
	var actual_position = get_children().size() - 2 
	move_child(new_input_node, actual_position) # so the warning is always at the bottom
	# Sets the child position so we can move it with the arrow up and down buttons
	new_input_node.position_child = actual_position
	new_input_node.initialize_input(new_input_manager)
	
	# connect remove and move buttons
	new_input_node.connect("move_node", Callable(self, "_on_move_node"))
	new_input_node.connect("remove_node", Callable(self, "_on_remove_node"))

	if def_input != null:
		new_input_manager.receive_input(default_input)

func _on_add_element_pressed():
	add_element(selected_type)


func _on_type_button_selected(index):
	selected_type = element_type_button.return_type_by_index(index)

func attempt_submit() -> Variant:
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
			input_manager.show_input_warning()
		return null
	
	return return_array

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
		
		input_managers.sort_custom(func(a, b): return a.array_position < b.array_position)

## Removes InputNode from the Array UI
func _on_remove_node(node: ArrayElementInput):
	input_managers.remove_at(input_managers.find(node.input))
	remove_child(node)

func receive_input(input):
	print(input)
	for element in input:
		add_element(typeof(element), element)
