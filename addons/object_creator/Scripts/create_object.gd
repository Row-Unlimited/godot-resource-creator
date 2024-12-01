@tool
class_name CreateObject
extends CreationWindow
## UI Window which creates custom input boxes for each property of the chosen class
## Checks if Inputs are correct by calling attempt_submit method in the InputManager objects

const PLUGIN_CONFIG_PATH = "res://addons/object_creator/PluginConfig.tres"

var test_input = preload("res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn")
var breakline = preload("res://addons/object_creator/Scenes/break_line.tscn")
var headline = preload("res://addons/object_creator/Scenes/UI Addon Scenes/headline.tscn")
var input_root_node: VBoxContainer
var submit_button: Button
var input_nodes: Array
var object_wrapper: ObjectWrapper
var property_list: Array

# these are given to CreateObject by CreationManager after instantiating
var object_chosen_callable: Callable
var object_edited_callable: Callable

var accept_empty_inputs

var SKIPPED_PROPERTIES =["resource_local_to_scene", "resource_path", "resource_name", "resource_scene_unique_id"]
var VECTOR_TYPES = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]


var menu_type = CreateMenuType.NORMAL
enum CreateMenuType {
	NORMAL,
	SETTINGS
}
# array that yields us the correct signal string with the enum ints as index
const type_to_output_signal = ["object_created", "settings_changed"]

signal object_created(object)
signal settings_changed(plugin_config_object)
## used when user clicks on an object input, should open a new object menu
signal create_sub_object_clicked(sub_object_wrapper)

func _ready() -> void:
	window_type = WindowType.CREATE_OBJECT

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
	input_root_node = get_node("ScrollContainer/VBoxContainer")
	submit_button = get_node("SubmitBox/CreateObject")
	submit_button.connect("pressed", Callable(self, "on_submit_pressed"))
	
	# sets up the window settings, so whether it is a special menu or whether it should accept empty inputs
	menu_set_up(create_menu_type)
	# filters out variables that are not export variables
	var export_var_lines = Helper.filter_lines(class_script.source_code, ["@export var"])
	var prune_lambda = func(x): return Helper.prune_string(x, "var", ":")
	export_var_lines = export_var_lines.map(prune_lambda)

	# Create UI for every single Input
	for property: Dictionary in property_list:
		var property_name = property["name"]

		var property_input_path = determine_input_type(property)
		if property_input_path != "" and not SKIPPED_PROPERTIES.has(property_name) and property_name in export_var_lines:
			var new_input : InputManager = load(property_input_path).instantiate()

			# connect sub resource signals to creation manager
			if property["type"] == TYPE_OBJECT:
				new_input.connect("edit_sub_object_clicked", object_edited_callable)
				new_input.connect("choose_class_button_clicked", object_chosen_callable)
				new_input.parent_wrapper = object_wrapper
			
			# give the sub-object callables to arr/dict since they can contain sub-objects
			if property["type"] in [TYPE_ARRAY, TYPE_DICTIONARY]:
				new_input.sub_obj_infos = {
					"edit_callable": object_edited_callable,
					"choose_callable": object_chosen_callable,
					"parent_wrapper": object_wrapper
					}

			add_breakline()

			# sets the accept_empty_inputs setting
			new_input.accept_empty_inputs = accept_empty_inputs
			
			input_root_node.add_child(new_input)
			new_input.initialize_input(property)

			input_nodes.append(new_input)
			if object_wrapper.obj:
				var object_pre_value = object_wrapper.obj.get(property_name)
				if typeof(object_pre_value) == property["type"] :
					new_input.receive_input(object_pre_value)
			
			new_input.set_up_config_rules(object_wrapper.class_config)
			

func determine_input_type(property: Dictionary) -> String:
	var vector_types = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]
	var scene_string: String
	match property["type"]:
		TYPE_BOOL:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn"
		TYPE_INT:
			if property["class_name"]:
				scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/enum_input.tscn"
			else:
				scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_FLOAT:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_STRING:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_NODE_PATH:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_DICTIONARY:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/dictionary_input.tscn"
		TYPE_ARRAY:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/array_input.tscn"
		TYPE_OBJECT:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/object_input.tscn"
		_:
			if vector_types.has(property["type"]):
				scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn"
			else:
				scene_string = ""
	return scene_string

## Handles the submit of the Object on the upper-most level
## Calls for all inputManager to submit their values and then it creates it into one big object
func on_submit_pressed():

	var properties: Dictionary
	for property in property_list:
		properties[property["name"]] = property

	var input_error_nodes: Array

	# so we dynamically swap signals, so we can use this to export for settings for example
	var output_signal = type_to_output_signal[menu_type]

	for input_node: InputManager in input_nodes:
		var input_value 
		if input_node.final_value != null:
			input_value = input_node.final_value
		else:
			input_value = input_node.attempt_submit()
		# if the output is an object wrapper only insert the obj into the actual property
		if input_value is ObjectWrapper:
			input_value = input_value.obj
		
		if input_value in Enums.InputErrorType:
			input_error_nodes.append(input_node)
		else:
			if not Helper.equal(input_value, Enums.InputResponse.IGNORE):
				var prop_name = input_node.property["name"]
				properties[prop_name]["value"] = input_value
			input_node.hide_input_warning()

	if input_error_nodes.is_empty():
		# TODO: fix error where empty strings have no "value" key in their property
		var return_wrapper = object_wrapper.create_object(properties) # potential async issue if object wrapper assigns new object to itself
		emit_signal(output_signal, return_wrapper)
		return return_wrapper
	else:
		for inputManager: InputManager in input_error_nodes:
			inputManager.show_input_warning(true)
		return Enums.InputErrorType.OBJECT_INVALID

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

## adds a headline with [paramname text] as String value at the top of the window
func add_headline(text: String):
	var new_headline = headline.instantiate()
	new_headline.text = text
	input_root_node.add_child(new_headline)
	input_root_node.move_child(new_headline, 0)

func add_breakline():
	input_root_node.add_child(breakline.instantiate())

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

func load_session(session_dict: Dictionary):
	var properties_dict = session_dict["properties"]
	for input_node in input_nodes:
		var input_name = input_node.property["name"]
		if input_name in properties_dict.keys():
			var parsed_property_dict = parse_property_dict_custom(properties_dict[input_name])
			input_node.receive_input(parsed_property_dict["value"])

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
				if other_type in VECTOR_TYPES:
					prop_value = Helper.custom_to_vector(prop_value)
		property_dict["value"] = prop_value
		return property_dict
