@tool
extends InputManager
## default input box used for int/String/float

var current_items: Array = []
var current_item: int = -1

func set_up_nodes():
	type_label = get_node("InputContainer/PropertyType")
	name_label = get_node("InputContainer/PropertyName")
	input_node = get_node("InputContainer/Input")
	input_warning = get_node("WarningContainer/WrongInputWarning")
	input_node.connect("item_selected", Callable(self, "_on_item_selected"))


func initialize_input(property_dict: Dictionary):
	if property_dict:
		property = property_dict
		set_up_nodes()
		set_property_information(property)
		style_input()
		create_enum_items()

func _ready() -> void:
	calc_minimum_size()

func calc_minimum_size():
	var max_child_size = get_node("InputContainer").get_children().map(func(x): return x.size.y).max()
	var stylebox = get_theme_stylebox("panel")
	custom_minimum_size.y = (max_child_size / 75) * 100 + stylebox.border_width_bottom + stylebox.border_width_top

func attempt_submit(mute_warnings=false) -> Variant:
	return current_item

func submit_status_dict():
	# if it's a property it has a name, if it's a sub_element like in an array it is empty
	var property_name = property["name"] if property else "" 
	var status_dict = {"value" : input_node.text, "type" : input_type, "name" : property_name}
	return status_dict

func create_enum_items():
	var item_strings = property["hint_string"].split(",")
	for item in item_strings:
		item = item.split(":")
		var item_name = item[0]
		var item_number = item[1].to_int()
		input_node.add_item(item_name, item_number)
		current_items.append({
			"item_name": item_name,
			"item_number": item_number
			})
	if current_items:
		_on_item_selected(0)


func style_input():
	name_label.text = property["name"]
	type_label.text = "Enum: " + property["class_name"]

func receive_input(input):
	if typeof(input) == TYPE_INT and input >= 0 and input < current_items.size():
		input_node.select(input)
		_on_item_selected(input)
	else:
		Helper.throw_error("Invalid default input for Enum Type InputManager")

func set_input_disabled(is_disabled: bool):
	input_node.disabled = is_disabled

func _on_item_selected(index: int):
	if index < 0:
		current_item = -1
		return
	current_item = index
	pass
