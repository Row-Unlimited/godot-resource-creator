@tool
class_name MultiElementInput
extends InputManager

var element_container_scene = preload("res://addons/object_creator/Scenes/Variable Input Scenes/multi_element_container.tscn")

var add_element_button: Button
var element_type_button: DataTypeOptionButton
var is_minimized = false
var add_element_section: HBoxContainer
var multi_input_vbox: VBoxContainer

var typed_object_type = null
var sub_obj_infos: Dictionary

var selected_type: Variant.Type = Variant.Type.TYPE_NIL
var input_managers: Array
var element_containers : Array

var input_scenes = {
	"default": preload("res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"),
	"bool": preload("res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn"),
	"vector": preload("res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn"),
	"array": load("res://addons/object_creator/Scenes/Variable Input Scenes/array_input.tscn"),
	"dictionary": load("res://addons/object_creator/Scenes/Variable Input Scenes/dictionary_input.tscn"),
	"object": preload("res://addons/object_creator/Scenes/Variable Input Scenes/object_input.tscn")
}
## holds the sub_config which describes how the items of this dict/arr behave
var sub_config: Dictionary

var included_types: Array = []

var focused_input: int = -1

## gets called first and is used to initialize values
func initialize_input(property_dict: Dictionary):
	property = property_dict
	set_up_nodes()
	if property_dict:
		name_label.text = property_dict["name"]
		input_type = property_dict["type"]

func set_up_nodes():
	multi_input_vbox = get_node("MarginContainer/MultiInputVBox")
	add_element_section = multi_input_vbox.get_node("AddElementSection")
	type_label = add_element_section.get_node("PropertyType")
	name_label = add_element_section.get_node("PropertyName")
	add_element_button = add_element_section.get_node("AddElementButton")
	element_type_button = add_element_section.get_node("ElementTypeButton")
	
	# connect buttons
	add_element_button.connect("pressed", _on_add_element_button_pressed)
	element_type_button.connect("item_selected", _on_type_button_selected)
	add_element_section.get_node("MinimizeButton").connect("pressed", _on_minimize_pressed)
	
	for type in TypeManager.get_all_values(TypeManager.TypeValue.READ_STRING):
		element_type_button.add_item(type)

	#if property:
	check_typed() # must be called after the items are added to the select button
	# select first type per default
	if element_type_button.item_count:
		_on_type_button_selected(0)

func check_typed():
	pass

## virtual function for dict/arr inputs to overide
func add_element(element_type: Variant.Type, def_input=null):
	pass

## called by array/dict scripts to create the scene of the child inputs
func create_scene_by_type(type: Variant.Type) -> Dictionary:
	var return_dict = {}
	var is_vector = false
	var new_scene: PackedScene

	new_scene = TypeManager.get_input_scene(type)
	if TypeManager.VECTOR_TYPES.has(type):
		is_vector = true
	var new_input_node: MultiElementContainer =  element_container_scene.instantiate()

	new_input_node.disabled_for_user = disable_editing # tell container to disable the move/delete buttons

	new_input_node.indent_level = indent_level + 1
	var new_input_manager = new_scene.instantiate()
	new_input_manager.indent_level = indent_level + 1
	input_managers.append(new_input_manager)
	new_input_manager.input_type = type

	#apply indent UI
	if type == TYPE_ARRAY or type == TYPE_DICTIONARY:
		new_input_manager.sub_obj_infos = sub_obj_infos # give sub_obj_infos to array/dict so they can connect object inputs
	
	multi_input_vbox.add_child(new_input_node) # add MultiElementContainer as new child

	var actual_position = multi_input_vbox.get_children().size() - 1
	multi_input_vbox.move_child(new_input_node, actual_position) # so the warning is always at the bottom
	# Sets the child position so we can move it with the arrow up and down buttons
	new_input_node.position_child = actual_position
	new_input_node.initialize_input(new_input_manager)
	# TODO: change once type dicts are out
	if type == TYPE_OBJECT: # set up object inputs with callables since they have to interact with the creation_manager
		new_input_manager.connect("edit_sub_object_clicked", sub_obj_infos["edit_callable"])
		new_input_manager.connect("choose_class_button_clicked", sub_obj_infos["choose_callable"])
		new_input_manager.parent_wrapper = sub_obj_infos["parent_wrapper"]

		if typed_object_type:
			new_input_manager.initialize_input({"class_name": typed_object_type})
		else:
			new_input_manager.initialize_input({})

	new_input_node.connect("remove_node", Callable(self, "_on_remove_node"))
	if config:
		new_input_manager.set_up_config_rules(config["ROOT"])
		if sub_config:
			new_input_manager.apply_config_rules([sub_config])

	on_elements_changed_size()

	var connect_focus_node = new_input_manager.input_node if new_input_manager.input_node else new_input_manager
	connect_focus_node.connect("focus_entered", _on_input_focus_changed)
	connect_focus_node.connect("focus_exited", _on_input_focus_changed)

	return_dict = {
		"is_vector": is_vector,
		"input_node": new_input_node,
		"input_manager": new_input_manager
		}
	return return_dict

func on_elements_changed_size():
	if range_max and not add_element_button.disabled:
		add_element_button.disabled = input_managers.size() >= range_max

## disables certain types so the select button can't choose them anymore
## [param include_types_only] makes it so only the values in types are enabled and all others are disabled
func disable_select_type_button(types: Array, include_types_only = false, is_remove = false):
	types = types.map(func(x): return TypeManager.find_type_value(x, TypeManager.TypeValue.READ_STRING))
	var item_count = element_type_button.item_count
	if disable_editing:
		for i in item_count:
			element_type_button.remove_item(item_count - i - 1)
		element_type_button.disabled = true
		return
	else:
		var remove_items = []
		for i in item_count:
			var should_be_disabled = element_type_button.get_item_text(i) in types
			should_be_disabled = should_be_disabled if not include_types_only else not should_be_disabled
			if is_remove and should_be_disabled:
				remove_items.append(i)
			else:
				element_type_button.set_item_disabled(i, should_be_disabled)

		if remove_items:
			remove_items.sort()
			remove_items.reverse()
			for index in remove_items:
				element_type_button.remove_item(index)
				
		# now select a not disabled button
		for i in element_type_button.item_count:
			if element_type_button.is_item_disabled(i) == false:
				element_type_button.select(i)
				element_type_button.emit_signal("item_selected", i)
				break

func apply_config_rules(configs_ordered: Array):
	# TODO: fix the remove button and maybe add config var that makes only the default elements not editable
	var last_config = configs_ordered.back()
	sub_config = last_config["SUB_ARRAY_CONFIG"] if "SUB_ARRAY_CONFIG" in last_config.keys() else {}
	super(configs_ordered)
	disable_select_type_button([], false, true)
	if included_types:
		disable_select_type_button(included_types, true, true)
	if disable_editing:
		add_element_button.disabled = true

func set_input_disabled(is_disabled: bool):
	add_element_button.disabled = is_disabled
	for input: InputManager in input_managers:
		input.set_input_disabled(is_disabled)

func check_submit_errors(value, error=null):
	var error_object = InputError.new_error_object([]) if error == null else error

	var is_in_range: bool
	if range_max != null and value.size() > range_max:
		is_in_range = false
	elif range_min != null and value.size() < range_min:
		is_in_range = false
	else:
		is_in_range = true

	if value.is_empty():
		value = return_empty_value(error_object)

	if not is_in_range:
		error_object.toggle_error("RANGE_INVALID", true)
	
	if error_object.is_ignore() or error_object.errors.is_empty():
		return value
	else:
		return error_object

#region signal_functions
func _on_type_button_selected(index):
	selected_type = element_type_button.return_type_by_index(index)

## Minimizes Arrays for better UX
func _on_minimize_pressed():
	for node: Node in multi_input_vbox.get_children():
		if node.name != "AddElementSection" and node.name != "Warning":
			node.visible = is_minimized
	if is_minimized:
		is_minimized = false
	else:
		is_minimized = true

func _on_add_element_button_pressed() -> void:
	add_element(selected_type)


func _on_input_focus_changed():
	var focus_before = focused_input
	focused_input = -1
	print(focus_before)

	for i in input_managers.size():
		var input = input_managers[i]
		if input.input_node:
			if input.input_node.has_focus():
				print(str(i) + " has focus")
				focused_input = i
				break
		elif input is MultiElementInput and input.focused_input > 0:
			focused_input = i
			break

	if focused_input > -1:
		if focus_before == -1:
			emit_signal("focus_entered")
			toggle_focus_shadow()
	elif focus_before > -1:
		emit_signal("focus_exited")
		toggle_focus_shadow()

#endregion
