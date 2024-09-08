@tool
extends InputManager

const vector_enum_types = [5, 6, 9, 10, 12, 13]


var isInt: bool


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
	var temp_value = input_node.return_input(accept_empty_inputs)
	if not check_input_range(temp_value) or temp_value == null:
		return_value = null
		show_input_warning(true)
	else:
		return_value = temp_value
	return return_value

func submit_status_dict():
	var value = "VECTOR::"+ str(input_node.return_input(true)) + "::"
	# if it's a property it has a name, if it's a sub_element like in an array it is empty
	var property_name = property["name"] if property else "" 
	var status_dict = {"value" : value, "type" : input_type, "name" : property_name}
	return status_dict

func receive_input(input):
	if is_vector(input):
		var input_values = []
		input_node.x_input.text = str(input.x)
		input_node.y_input.text = str(input.y)
		if(typeof(input) > 6):
			input_node.z_input.text = str(input.z)
			if(typeof(input) > 10):
				print(input)
				input_node.wInput.text = str(input.w)
	else:
		assert(false, "Error: you are trying to input a non vector object to a vector input")

func is_vector(input) -> bool:
	return typeof(input) in vector_enum_types
