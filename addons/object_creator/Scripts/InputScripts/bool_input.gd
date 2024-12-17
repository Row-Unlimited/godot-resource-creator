@tool
extends InputManager

var toggle_status = false

func set_up_nodes():
	type_label = get_node("InputContainer/PropertyType")
	name_label = get_node("InputContainer/PropertyName")
	input_node = get_node("InputContainer/Input")


func initialize_input(property_dict: Dictionary):
	type_label = get_node("InputContainer/PropertyType")
	name_label = get_node("InputContainer/PropertyName")
	input_node = get_node("InputContainer/Input")
	input_node.connect("toggled", Callable(self, "on_toggled"))
	
	if property_dict:
		set_property_information(property_dict)
		type_label.text = return_type_string(property["type"])

func _ready() -> void:
	calc_minimum_size()

func calc_minimum_size():
	var max_child_size = get_node("InputContainer").get_children().map(func(x): return x.size.y).max()
	var stylebox = get_theme_stylebox("panel")
	custom_minimum_size.y = (max_child_size / 75) * 100 + stylebox.border_width_bottom + stylebox.border_width_top

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
