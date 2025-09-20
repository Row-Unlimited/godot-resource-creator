@tool
class_name CreateObject
extends TabScreen
## UI Window which creates custom input boxes for each property of the chosen class
## Checks if Inputs are correct by calling attempt_submit method in the InputManager objects

enum CreateMenuType {
	NORMAL,
	SETTINGS
}

const SKIPPED_PROPERTIES =["resource_local_to_scene", "resource_path", "resource_name", "resource_scene_unique_id"]
const PLUGIN_CONFIG_PATH = "res://addons/object_creator/PluginConfig.tres"
## array that yields us the correct signal string with the enum ints as index
const MENU_TYPE_OUTPUT_SIGNAL = ["object_created", "settings_changed"]
const HEADLINE_SCENE = preload("res://addons/object_creator/Scenes/UI Addon Scenes/headline.tscn")

var menu_type = CreateMenuType.NORMAL

var input_root_node: VBoxContainer
var input_nodes: Array
var object_wrapper: ObjectWrapper
var property_list: Array

var session_dict : Dictionary

# these are given to CreateObject by CreationManager after instantiating
var object_chosen_callable: Callable
var object_edited_callable: Callable
var delete_wrapper_callable: Callable
var accept_empty_inputs

@onready var submit_button: Button = get_node("SubmitBox/CreateObject")
@onready var toggle_json_button: CheckButton = get_node("SubmitBox/ToggleJsonButton")
@onready var toggle_hidden_button: CheckButton = get_node("SubmitBox/ToggleViewHidden")
@onready var export_path_edit: LineEdit = get_node("SubmitBox/ExportPathEdit")

signal object_created(object)
signal settings_changed(plugin_config_object)
## used when user clicks on an object input, should open a new object menu
signal create_sub_object_clicked(sub_object_wrapper)

func _ready() -> void:
	submit_button.connect("pressed", on_submit_pressed)
	toggle_json_button.connect("toggled", _on_toggle_json)
	toggle_hidden_button.connect("toggled", _on_toggle_hidden)
	
	if not object_wrapper is ObjectWrapper: # suppresses error at starting of project, but no idea why the plugin calls create_object without any clicks on a create object button
		return
	
	if object_wrapper.parent_wrapper:
		toggle_json_button.disabled = true
	
	if object_wrapper.export_path:
		export_path_edit.text = object_wrapper.export_path
	if object_wrapper.class_config and "is_export_path_static" in object_wrapper.class_config.keys():
		export_path_edit.editable = not object_wrapper.class_config["is_export_path_static"]
	
	get_node("ScaleAssistant")._on_scale_node_ready()

## Creates the create_object menu UI and Logic[br]
## takes the class from the object_wrapper and gets the property list[br]
## then it filters out all the properties that are skipped or non-export vars
## and creates an Input Manager for every not filtered Property according to their Type
func initialize_UI(object_wrapper, create_menu_type: CreateMenuType = CreateMenuType.NORMAL):
	# TODO: add button that appears if the object is a sub_object so you can easily navigate to the parent object
	self.object_wrapper = object_wrapper
	# create object of the class from the script path and get the property list
	var class_script: Script = load(object_wrapper.path)
	property_list = class_script.get_script_property_list()
	input_root_node = get_node("ScrollContainer/MarginContainer/InputContainer")
	property_list = find_tooltip_comments(property_list, class_script.source_code)

	# sets up the window settings, so whether it is a special menu or whether it should accept empty inputs
	menu_set_up(create_menu_type)
	# filters out variables that are not export variables
	var export_var_lines = Helper.filter_lines(class_script.source_code, ["@export var"])
	var prune_lambda = func(x): return Helper.prune_string(x, "var", ":")
	export_var_lines = export_var_lines.map(prune_lambda)

	# Create UI for every single Input
	for property: Dictionary in property_list:
		var property_name = property["name"]
		var property_type = property["type"]

		if property_type in TypeManager.SUPPORTED_TYPES and not SKIPPED_PROPERTIES.has(property_name) and property_name in export_var_lines:
			var property_input_scene = TypeManager.get_input_scene(property_type, property)
			var new_input : InputManager = property_input_scene.instantiate()

			new_input.connect("error_occurred", _on_error_occurred)
			# connect sub resource signals to creation manager
			if property_type == TYPE_OBJECT:
				new_input.connect("edit_sub_object_clicked", object_edited_callable)
				new_input.connect("choose_class_button_clicked", object_chosen_callable)
				new_input.connect("wrapper_removed", delete_wrapper_callable)
				new_input.parent_wrapper = object_wrapper
			
			# give the sub-object callables to arr/dict since they can contain sub-objects
			if property_type in [TYPE_ARRAY, TYPE_DICTIONARY]:
				new_input.sub_obj_infos = {
					"edit_callable": object_edited_callable,
					"choose_callable": object_chosen_callable,
					"delete_wrapper_callable": delete_wrapper_callable,
					"parent_wrapper": object_wrapper
					}

			# sets the accept_empty_inputs setting
			new_input.accept_empty_inputs = accept_empty_inputs
			
			input_root_node.add_child(new_input)
			new_input.initialize_input(property)

			input_nodes.append(new_input)
			if object_wrapper.obj:
				var object_pre_value = object_wrapper.obj.get(property_name)
				if typeof(object_pre_value) == property_type :
					new_input.has_been_saved = true
					new_input.receive_input(object_pre_value)
			
			new_input.set_up_config_rules(object_wrapper.class_config)

## Handles the submit of the Object on the upper-most level
## Calls for all inputManager to submit their values and then it creates it into one big object
func on_submit_pressed():
	var properties: Dictionary
	for property in property_list:
		properties[property["name"]] = property

	var input_error_nodes: Array

	# so we dynamically swap signals, so we can use this to export for settings for example
	var output_signal = MENU_TYPE_OUTPUT_SIGNAL[menu_type]

	for input_node: InputManager in input_nodes:
		var input_value 
		if input_node.final_value != null:
			input_value = input_node.final_value
		else:
			input_value = input_node.attempt_submit()
		# if the output is an object wrapper only insert the obj into the actual property
		if input_value is ObjectWrapper:
			input_value = input_value.obj

		if input_value is InputError and input_value.has_any_errors():
			input_error_nodes.append(input_node)
		else:
			if not (input_value is InputError and input_value.is_ignore()):
				var prop_name = input_node.property["name"]
				properties[prop_name]["value"] = input_value
			input_node.hide_input_warning()

	if input_error_nodes.is_empty():
		# TODO: fix error where empty strings have no "value" key in their property
		if DirAccess.dir_exists_absolute(export_path_edit.text):
			object_wrapper.export_path = export_path_edit.text
		var return_wrapper = object_wrapper.create_object(properties) # potential async issue if object wrapper assigns new object to itself
		emit_signal(output_signal, return_wrapper)
		object_wrapper.save_dict = save_session()
		return return_wrapper
	else:
		return InputError.new_error_object(["OBJECT_INVALID"])

## function we use to customize the create_object menu so it can be used for settings or other purposes
## also implements settings for the creation process
func menu_set_up(create_menu_type: CreateMenuType):
	var config_object : PluginConfig = load(PLUGIN_CONFIG_PATH)
	accept_empty_inputs = config_object.accept_empty_inputs
	
	match create_menu_type:
		CreateMenuType.SETTINGS:
			create_settings_menu()
		_:
			create_default_menu()
			

## sets up default variables for create_object menu
func create_default_menu():
	add_headline(object_wrapper.file_class_name)

## sets up special variables for the settings create_object menu
func create_settings_menu():
	add_headline("Settings")
	menu_type = CreateMenuType.SETTINGS
	var submit_panel = get_node("SubmitBox")
	submit_panel.get_node("CreateObject").text = "Save Settings"
	var create_elements = submit_panel.get_children().filter(func(x): return x.name != "CreateObject" )
	for element in create_elements:
		element.visible = false

## adds a headline with [paramname text] as String value at the top of the window
func add_headline(text: String):
	var new_headline = HEADLINE_SCENE.instantiate()
	new_headline.text = text
	input_root_node.add_child(new_headline)
	input_root_node.move_child(new_headline, 0)

func find_tooltip_comments(property_list: Array, source_code: String):
	var var_comments = Helper.get_export_var_docs(property_list, source_code)
	for i in property_list.size():
		var var_name = property_list[i]["name"]
		if not var_name in var_comments.keys():
			continue
		else:
			var comments =  var_comments[var_name]
			comments = Helper.format_doc_strings(comments)
			property_list[i]["tooltip_docs"] = comments
	return property_list

## Saves the current creation status as a dict. [br]
## Every InputManager returns a Dict with a [b]property name[/b] key or 
## a [b]value[/b] key for sub inputs (like in arrays) even if the value is empty [br]
## [b]Format:[/b] [br]
## 			- Simple Variables are safed as string values [br]
##			- bool will be safed as strings "BOOL_TRUE" or "BOOL_FALSE" [br]
##			- Arrays are safed as actual Arrays with a dict value for each element 
##			the dicts have: [br]
##				+ a key "type" with Variant.type int values [br]
##				+ a key "class" for the object class if type is an object [br]
## 				+ a key "value" with the string input [br]
##			- Dictionaries will be safed as actual dicts, and the values will be dicts analogous to the arrays [br]
##			- Vectors will be safed as strings of the format: [br]
##				VECTOR::<value>,<value>,<value>,<value>::
func save_session():
	var save_dict: Dictionary = {"name": object_wrapper.file_class_name, "class_path": object_wrapper.path}
	var properties_dict = {}
	
	for input_node: InputManager in input_nodes:
		var status_dict = input_node.submit_status_dict()
		if status_dict != null:
			var status_dict_key =status_dict["name"]
			properties_dict[status_dict_key] = status_dict
	
	save_dict["properties"] = properties_dict
	save_dict["object_wrapper"] = object_wrapper

	session_dict = save_dict
	return save_dict.duplicate()

## parses back our session dict so the input managers can use it as input
func parse_property_dict_custom(property_dict: Dictionary):
		var prop_type = property_dict["type"]
		var prop_value = property_dict["value"]
		
		match prop_type:
			TYPE_BOOL:
				prop_value = true if prop_value == "BOOL_TRUE" else false
			TYPE_ARRAY:
				for i in prop_value.size():
					prop_value[i] = parse_property_dict_custom(prop_value[i])["value"]
			TYPE_DICTIONARY:
				for key in prop_value.keys():
					prop_value[key] = parse_property_dict_custom(prop_value[key])["value"]
			var other_type:
				if other_type in TypeManager.VECTOR_TYPES:
					prop_value = Helper.custom_to_vector(prop_value)
		property_dict["value"] = prop_value
		return property_dict

func _on_toggle_json(toggle_mode):
	object_wrapper.export_as_json = toggle_mode

func _on_toggle_hidden(toggle_mode):
	for node: InputManager in input_nodes:
		if node.hide_input:
			node.visible = toggle_mode

## if an error occurred it scrolls the scrollbar so the center of the input is visible on the screen and the user sees that an error occurred.
func _on_error_occurred(input: InputManager):
	var input_rect = input.get_global_rect()

	if get_global_rect().size.y < input_rect.get_center().y:
		var scroll_container: ScrollContainer = get_node("ScrollContainer")
		var local_input_center = input_rect.get_center().y - get_global_rect().position.y
		scroll_container.scroll_vertical = local_input_center
