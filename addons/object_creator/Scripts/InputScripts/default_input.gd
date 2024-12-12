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
	var error_object = InputError.new_error_object(["TYPE_INVALID"])
	var return_value
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
	# check for the different cases and return an enum InputError value for better warnings
	if return_value or accept_empty:
		error_object.toggle_error("TYPE_INVALID")

	if temp_value.is_empty():
		return_value = return_empty_value(error_object)
	elif check_range_invalid(return_value):
		error_object.toggle_error("RANGE_INVALID", true)

	if error_object.has_any_errors() or return_value == null:
		return error_object
	else:
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
	var acceptable_types = [TYPE_INT, TYPE_FLOAT, TYPE_STRING]
	if typeof(input) in acceptable_types:
		input_node.text = str(input)
	else:
		assert(false, "DEFAULTVALUE-ERROR: default_value type not of acceptable types: " + str(acceptable_types))

func set_input_disabled(is_disabled: bool):
	input_node.editable = not is_disabled

func check_range_invalid(input: Variant) -> bool:
	var return_bool = false
	match input_type:
		TYPE_INT:
			return_bool = not ((range_max == null or range_max >= input) and (range_min == null or range_min <= input))
		TYPE_FLOAT:
			return_bool = not ((range_max == null or range_max >= input) and (range_min == null or range_min <= input))
		TYPE_STRING:
			return_bool = not ((range_max == null or range_max >= input.length()) and (range_min == null or range_min <= input.length()))
	return return_bool
