@tool
class_name CreateObject
extends Control
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

var skipped_properties =["resource_local_to_scene", "resource_path", "resource_name"]

var menu_type = CreateMenuType.NORMAL
enum CreateMenuType {
	NORMAL,
	SETTINGS
}
# array that yields us the correct signal string with the enum ints as index
const type_to_output_signal = ["object_created", "settings_changed"]

signal object_created(object)
signal settings_changed(plugin_config_object)

func initialize_UI(cObject: ClassObject, create_menu_type: CreateMenuType = CreateMenuType.NORMAL):
	class_object = cObject
	# create object of the class from the script path and get the property list
	property_list = load(class_object.path).new().get_property_list()
	input_root_node = get_node("ScrollContainer/VBoxContainer")
	submit_button = get_node("SubmitBox/CreateObject")
	submit_button.connect("pressed", Callable(self, "on_submit_pressed"))
	
	# sets up the window settings, so whether it is a special menu or whether it should accept empty inputs
	menu_set_up(create_menu_type)

	# Create UI for every single Input
	for property: Dictionary in property_list:
		var property_input_path = determine_input_type(property)
		if property_input_path != "" and not skipped_properties.has(property["name"]):
			var new_input : InputManager = load(property_input_path).instantiate()
			
			add_breakline()

			# sets the accept_empty_inputs setting
			new_input.accept_empty_inputs = accept_empty_inputs
			
			input_root_node.add_child(new_input)
			if (property_input_path.contains("array")):
				new_input.array_input = load(property_input_path)
			new_input.initialize_input(property)

			input_nodes.append(new_input)

			if cObject.premade_object:
				var object_pre_value = cObject.premade_object.get(property["name"])
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
			inputManager.show_input_warning()
		return

## function we use to customize the create_object menu so it can be used for settings or other purposes
## also implements settings for the creation process
func menu_set_up(create_menu_type: CreateMenuType):
	var config_object : PluginConfig = load(PLUGIN_CONFIG_PATH)
	accept_empty_inputs = config_object.accept_empty_inputs
	
	match create_menu_type:
		CreateMenuType.SETTINGS:
			create_settings_menu()
			


func create_settings_menu():
	add_headline("Settings")
	menu_type = CreateMenuType.SETTINGS

func add_headline(text: String):
	var new_headline = headline.instantiate()
	new_headline.text = text
	input_root_node.add_child(new_headline)
	input_root_node.move_child(new_headline, 0)

func add_breakline():
	input_root_node.add_child(breakline.instantiate())
