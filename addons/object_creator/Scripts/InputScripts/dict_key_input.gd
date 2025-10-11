@tool
class_name DictKeyInput
extends InputManager
## input used in multi_element_container to allow for key creation of a multitude of types

var key_type_button: OptionButton
var key_type: Variant.Type
var key_object_type: String
var sub_obj_infos: Dictionary

func _ready() -> void:
	# setup nodes
	input_container = get_node("MarginContainer/KeyInputSection")
	key_type_button = input_container.get_node("KeyTypeButton")
	key_type_button.clear()
	for type in TypeManager.get_all_values(TypeManager.TypeValue.READ_STRING):
		if key_type == 0 or TypeManager.TYPE_MAPPING[type][TypeManager.TypeValue.TYPE_ENUM] == key_type:
			key_type_button.add_item(type)
	
	key_type_button.connect("item_selected", on_type_selected)
	on_type_selected(0)


func attempt_submit(mute_warnings=false) -> Variant:
	var error_object = InputError.new_error_object(["TYPE_INVALID"])
	var return_value = null
	var temp_value
	if input_node:
		temp_value = input_node.attempt_submit()
	
	if TypeManager.is_empty_value(temp_value):
		return_value = return_empty_value(error_object)
	else:
		return_value = temp_value
		
	if return_value != null:
		error_object.toggle_error("TYPE_INVALID")

	if error_object.has_any_errors() or return_value == null:
		current_errors = error_object
		show_input_warning(error_object)
		return error_object
	else:
		return return_value

func submit_status_dict():
	pass

func style_input():
	name_label.text = property["name"]
	type_label.text = TypeManager.find_type_value(property["type"], TypeManager.TypeValue.READ_STRING)

func receive_input(input):
	pass

func set_input_disabled(is_disabled: bool):
	pass

func on_type_selected(index: int):
	var type_name = key_type_button.get_item_text(index)
	var new_type = TypeManager.find_type_value(type_name)[0]
	var new_input_scene = TypeManager.get_input_scene(new_type)
	if input_node:
		input_node.free()
	
	input_node = new_input_scene.instantiate()
	input_container.add_child(input_node)
	input_container.move_child(input_node, 0)
	var property_dict_custom = {"type": new_type}
	if key_object_type:
		property_dict_custom["class_name"] = key_object_type
		input_node.connect("edit_sub_object_clicked", sub_obj_infos["edit_callable"])
		input_node.connect("choose_class_button_clicked", sub_obj_infos["choose_callable"])
		input_node.connect("wrapper_removed", sub_obj_infos["delete_wrapper_callable"])
	input_node.initialize_input(property_dict_custom)
	input_node.ui_status = InputManager.UiStatus.MINIMUM
	# TODO: make UI adequate by removing/changing themes
