@tool
extends InputManager

const vector_enum_types = [5, 6, 9, 10, 12, 13]


var is_int: bool


func set_up_nodes():
	type_label = get_node("InputContainer/PropertyType")
	name_label = get_node("InputContainer/PropertyName")
	input_node = get_node("InputContainer/Input")
	input_warning = get_node("WarningContainer/WrongInputWarning")
	type_label.text = return_type_string(input_type)
	input_node.create_vector_UI(input_type)

func initialize_input(property_dict: Dictionary):
	type_label = get_node("InputContainer/PropertyType")
	name_label = get_node("InputContainer/PropertyName")
	input_node = get_node("InputContainer/Input")
	input_warning = get_node("WarningContainer/WrongInputWarning")
	
	set_property_information(property_dict)
	type_label.text = return_type_string(input_type)
	input_node.create_vector_UI(input_type)
	

func attempt_submit(mute_warnings=false) -> Variant:
	var return_value = null
	return input_node.return_input()
	# TODO: maybe do something if errors occur

func submit_status_dict():
	var value = "VECTOR::"+ str(input_node.return_input()) + "::"
	# if it's a property it has a name, if it's a sub_element like in an array it is empty
	var property_name = property["name"] if property else "" 
	var status_dict = {"value" : value, "type" : input_type, "name" : property_name}
	return status_dict

func receive_input(input):
	if typeof(input) in [TYPE_ARRAY, TYPE_STRING]:
		input = Helper.custom_to_vector(input)
	
	if not is_vector(input):
		assert(false, "Error: you are trying to input a non vector object to a vector input")
		return
	var input_values = []
	input_node.x_input.text = str(input.x)
	input_node.y_input.text = str(input.y)
	if(typeof(input) > 6):
		input_node.z_input.text = str(input.z)
		if(typeof(input) > 10):
			input_node.w_input.text = str(input.w)

func is_vector(input) -> bool:
	return typeof(input) in vector_enum_types

func apply_config_rules(configs_ordered: Array):
	super(configs_ordered)
	input_node.accept_empty = accept_empty
	input_node.change_empty_default = change_empty_default

func set_input_disabled(is_disabled: bool, target_specifier: Array = []):
	for i in input_node.input_array.size():
		if i in target_specifier or target_specifier.is_empty():
			input_node.input_array[i].editable = not is_disabled
