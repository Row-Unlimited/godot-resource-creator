@tool
class_name ArrayInput
extends MultiElementInput
## This class Handles Array_inputs as InputManager
## Uses multi_element_container as InputNodes for the UI of the Inputs.
## InputManager Objects are stored in input_managers array and sorted when UI nodes are moved

func check_typed():
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
		disable_select_type_button([type_arr], true, true)
	else:
		# TODO  find solution
		assert(false, "unsupported type in typed array")

## adds a new element to the input UI
## loads the correct InputManager and puts it into an MultiElementContainer		
func add_element(element_type: Variant.Type, def_input=null):
	var result_dict = create_scene_by_type(element_type)
	var is_vector = result_dict["is_vector"]
	var new_input_node: MultiElementContainer = result_dict["input_node"]
	var new_input_manager: InputManager = result_dict["input_manager"]
	
	# connect remove and move buttons
	new_input_node.connect("move_node", Callable(self, "_on_move_node"))
	if def_input != null:
		new_input_manager.receive_input(def_input)

func attempt_submit(mute_warnings=false) -> Variant:
	var missing_input_nodes = []
	var return_array = []
	for input_manager: InputManager in input_managers:
		var input_value = input_manager.attempt_submit()
		if not input_value in Enums.InputErrorType:
			input_manager.hide_input_warning()
			return_array.append(input_value)
		elif input_value == Enums.InputResponse.IGNORE:
			pass
		else:
			missing_input_nodes.append(input_manager)
			# TODO: call input warning method with type
	
	if missing_input_nodes:
		# TODO: maybe add behavior that accepts certain empty fields or something
		return Enums.InputErrorType.INVALID
	
	if return_array.is_empty():
		return return_empty_value()

	return return_array

func submit_status_dict():
	var value_list = [] # value of the status_dict; Contains all input nodes status_dicts
	for input_manager in input_managers:
		value_list.append(input_manager.submit_status_dict())
	
	# if it's a property it has a name, if it's a sub_element like in an array it is empty
	var property_name = property["name"] if property else "" 
	var status_dict = {"value" : value_list, "type" : input_type, "name" : property_name}
	return status_dict

## takes an array and fills the input with input fields for each array element
func receive_input(input):
	for element in input:
		add_element(typeof(element), element)

#region signal_methods

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
#endregion
