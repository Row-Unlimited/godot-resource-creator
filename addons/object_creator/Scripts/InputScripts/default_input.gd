@tool
extends InputManager
## default input box used for int/String/float

func set_up_nodes():
	type_label = get_node("InputContainer/PropertyType")
	name_label = get_node("InputContainer/PropertyName")
	input_node = get_node("InputContainer/Input")
	input_warning = get_node("WarningContainer/WrongInputWarning")
	type_label.text = return_type_string(input_type)


func initialize_input(property_dict: Dictionary):
	if property_dict:
		set_up_nodes()
		set_property_information(property_dict)
		style_input()

func attempt_submit(mute_warnings=false) -> Variant:
	var return_value = null
	var temp_value: String = input_node.text
	match input_type:
		Variant.Type.TYPE_INT:
			if temp_value.is_valid_int():
				return_value = temp_value.to_int()
		Variant.Type.TYPE_FLOAT:
			if temp_value.is_valid_float():
				return_value = temp_value.to_float()
		Variant.Type.TYPE_STRING:
			if not temp_value.is_empty():
				return_value = temp_value

	# if accept_empty_input setting is activated empty values will be turned into the default
	if temp_value.is_empty() and accept_empty_inputs:
		return_value = return_empty_by_type()

	if not check_input_range(return_value) or return_value == null:
		return_value = null
		show_input_warning(true)
	return return_value

func submit_status_dict():
	# if it's a property it has a name, if it's a sub_element like in an array it is empty
	var property_name = property["name"] if property else "" 
	var status_dict = {"value" : input_node.text, "type" : input_type, "name" : property_name}
	return status_dict

func style_input():
	name_label.text = property["name"]
	type_label.text = return_type_string(property["type"])

func receive_input(input):
	input_node.text = str(input)
