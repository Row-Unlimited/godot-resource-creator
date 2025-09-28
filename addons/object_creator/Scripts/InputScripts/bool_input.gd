@tool
extends InputManager

var toggle_status = false

func initialize_input(property_dict: Dictionary):
	# setup nodes
	input_container = get_node("MarginContainer/InputContainer")
	type_label = input_container.get_node("PropertyType")
	name_label = input_container.get_node("PropertyName")
	input_node = input_container.get_node("Input")
	input_node.connect("toggled", on_toggled)

	if property_dict:
		set_property_information(property_dict)
		type_label.text = TypeManager.find_type_value(property["type"], TypeManager.TypeValue.READ_STRING)
	
	remove_unused_nodes()

func remove_unused_nodes():
	if name_label and name_label.text.is_empty():
		name_label.free()
		if input_container.get_child(0) is MarginContainer:
			input_container.get_child(0).free()

func attempt_submit(mute_warnings=false) -> Variant:
	
	return toggle_status

func submit_status_dict():
	var value_converted = "BOOL_TRUE" if toggle_status else "BOOL_FALSE"
	# if it's a property it has a name, if it's a sub_element like in an array it is empty
	var property_name = property["name"] if property else "" 
	var status_dict = {"value" : value_converted, "type" : input_type, "name" : property_name}
	return status_dict

func on_toggled(toggled_on):
	toggle_status = toggled_on

func receive_input(input):
	input_node.set_pressed_no_signal(input)
	input_node._toggled(input)
	toggle_status = input

func set_input_disabled(is_disabled: bool):
	input_node.disabled = is_disabled
