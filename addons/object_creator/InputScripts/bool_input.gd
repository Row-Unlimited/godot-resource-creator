@tool
extends InputManager

var toggle_status = false

func set_up_nodes():
	type_label = get_node("InputContainer/PropertyType")
	name_label = get_node("InputContainer/PropertyName")
	input_node = get_node("InputContainer/Input")
	input_warning = get_node("WarningContainer/WrongInputWarning")


func initialize_input(property_dict: Dictionary):
	type_label = get_node("InputContainer/PropertyType")
	name_label = get_node("InputContainer/PropertyName")
	input_node = get_node("InputContainer/Input")
	input_warning = get_node("WarningContainer/WrongInputWarning")
	input_node.connect("toggled", Callable(self, "on_toggled"))
	
	set_property_information(property_dict)
	type_label.text = return_type_string(property["type"])

func attempt_submit() -> Variant:
	
	return toggle_status

func on_toggled(toggled_on):
	toggle_status = toggled_on

func receive_input(input):
	input_node.toggle_mode = input
	toggle_status = input
