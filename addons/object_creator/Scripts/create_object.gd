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
var class_object: ClassObject
var property_list: Array

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
signal create_sub_object_clicked(sub_class_object)

func _ready() -> void:
	window_type = WindowType.CREATE_OBJECT

## Creates the create_object menu UI and Logic[br]
## takes the class from the class_object and gets the property list[br]
## then it filters out all the properties that are skipped or non-export vars
## and creates an Input Manager for every not filtered Property according to their Type
func initialize_UI(cObject: ClassObject, create_menu_type: CreateMenuType = CreateMenuType.NORMAL):
	class_object = cObject
	# create object of the class from the script path and get the property list
	property_list = load(class_object.path).new().get_property_list()
	input_root_node = get_node("ScrollContainer/VBoxContainer")
	submit_button = get_node("SubmitBox/CreateObject")
	submit_button.connect("pressed", Callable(self, "on_submit_pressed"))
	
	# sets up the window settings, so whether it is a special menu or whether it should accept empty inputs
	menu_set_up(create_menu_type)

	# filters out variables that are not export variables
	var export_var_lines = Helper.filter_lines(load(class_object.path).new().get_script().source_code, ["@export var"])
	var prune_lambda = func(x): return Helper.prune_string(x, "var", ":")
	export_var_lines = export_var_lines.map(prune_lambda)

	# Create UI for every single Input
	for property: Dictionary in property_list:
		var property_name = property["name"]

		var property_input_path = determine_input_type(property)
		if property_input_path != "" and not SKIPPED_PROPERTIES.has(property_name) and property_name in export_var_lines:
			var new_input : InputManager = load(property_input_path).instantiate()
			
			add_breakline()

			# sets the accept_empty_inputs setting
			new_input.accept_empty_inputs = accept_empty_inputs
			
			input_root_node.add_child(new_input)
			new_input.initialize_input(property)

			input_nodes.append(new_input)

			if cObject.premade_object:
				var object_pre_value = cObject.premade_object.get(property_name)
				if typeof(object_pre_value) == property["type"] :
					new_input.receive_input(object_pre_value)
			

func determine_input_type(property: Dictionary) -> String:
	var vector_types = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]
	var scene_string: String
	match property["type"]:
		TYPE_BOOL:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn"
		TYPE_INT:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_FLOAT:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_STRING:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_NODE_PATH:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn"
		TYPE_CALLABLE:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/callable_input.tscn"
		TYPE_DICTIONARY:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/dictionary_input.tscn"
		TYPE_ARRAY:
			scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/array_input.tscn"
		_:
			if vector_types.has(property["type"]):
				scene_string = "res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn"
			else:
				scene_string = ""
	return scene_string

## Handles the submit of the Object on the upper-most level
## Calls for all inputManager to submit their values and then it creates it into one big object
func on_submit_pressed():
	var temp_object: Object = load(class_object.path).new()
	var missing_inputNodes: Array

	save_session()

	# so we dynamically swap signals, so we can use this to export for settings for example
	var output_signal = type_to_output_signal[menu_type]
	
	for input_node: InputManager in input_nodes:
		var input_value = input_node.attempt_submit()
		if input_value != null:
			temp_object.set(input_node.property["name"], input_value)
			input_node.hide_input_warning()
		else:
			missing_inputNodes.append(input_node)

	if missing_inputNodes.is_empty():
		emit_signal(output_signal, temp_object)
	else:
		for inputManager: InputManager in missing_inputNodes:
			inputManager.show_input_warning(true)
		return

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
	add_headline(class_object.name_class)

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
	var save_dict: Dictionary = {"name": class_object.name_class, "class_path": class_object.path}
	var properties_dict = {}
	
	for input_node: InputManager in input_nodes:
		var status_dict = input_node.submit_status_dict()
		if status_dict != null:
			var status_dict_key =status_dict["name"]
			properties_dict[status_dict_key] = status_dict
	
	save_dict["properties"] = properties_dict
	save_dict["class_object"] = class_object

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
					prop_value = Helper.string_to_vector(prop_value)
		property_dict["value"] = prop_value
		return property_dict
