@tool
class_name InputManager
extends PanelContainer
## Parent Class of all Input Scenes
## Should in essence be regarded as an abstract class

var property: Dictionary
var input_type: Variant.Type
var name_label
var type_label
var input_node
var input_container: Container
var array_position: int # position if inputmanager is within an array
var accept_empty_inputs : bool
var tooltip_string: String = ""

var current_errors: InputError
@onready var error_color = load("res://addons/object_creator/PluginConfig.tres").error_color

#region ui_variables
var indent_level = 0
var base_panel_resource = "res://addons/object_creator/Assets/ThemeAssets/DefaultTheme/multi_input_indent_panels/input_panel_base.tres"
const indent_panel_resources = [
 	"res://addons/object_creator/Assets/ThemeAssets/DefaultTheme/multi_input_indent_panels/indent_panel_0.tres",
 	"res://addons/object_creator/Assets/ThemeAssets/DefaultTheme/multi_input_indent_panels/indent_panel_1.tres",
	"res://addons/object_creator/Assets/ThemeAssets/DefaultTheme/multi_input_indent_panels/indent_panel_2.tres"
	]
#endregion

## variable to keep track of if the variable has been saved already or is new, so that default values aren't reapplied
var has_been_saved: bool = false

#region config_variables
## range describes number range for int/float and size range for string/array/dictionary
var config
var range_max = null
var range_min = null
var accept_empty: bool = true
var change_empty_default: bool = false
var disable_editing: bool = false
var default_value
var hide_input: bool = false
var final_value = null
#endregion

signal error_occurred(input_manager)

## set up function that is called by the CreateObject class [br]
## is the first function that is called, before the ready func
func initialize_input(property_dict: Dictionary):
	property = property_dict

func set_up_nodes():
	pass

## virtual function that is redefined in each input
## inputs have name labels that are empty when it's not a property but a cell in an array
## this function should be used to remove these empty nodes so the UI is more compact
func remove_unused_nodes():
	# TODO: also implement it to remove type node when it is a typed array. But first types need to be shown more  specifically in the actual array input so like Array[Type] instead of just Array
	pass

func _ready() -> void:
	if input_node:
		input_node.connect("focus_entered", _on_input_focus_changed)
		input_node.connect("focus_exited", _on_input_focus_changed)

	if property and "tooltip_docs" in property.keys():
		tooltip_string = property["tooltip_docs"]
		tooltip_text = tooltip_string
	set_indent_color()
	if material and material is ShaderMaterial:
		material.set_shader_parameter("error_color", error_color)

func attempt_submit(mute_warnings=false) -> Variant:
	var return_value
	return return_value

## Parent Virtual Function for all input Managers to bring their input into a save format
## So the CreateObject class can save it
func submit_status_dict() -> Dictionary:
	# TODO: I should consider moving the dict creation in this parent function and only changing the value in the sub_functions
	return {}

func set_up_config_rules(config):
	if not config:
		return
	self.config = Helper.flatten_sub_dicts(config)
	var config_strings = ["CLASS_GENERAL_CONFIG", TypeManager.find_type_value(input_type, TypeManager.TypeValue.TYPE_ENUM_STRING)]
	config_strings = config_strings + [property["name"]] if property and "name" in property.keys() else config_strings
	config_strings = config_strings.filter(func(x): return x in self.config.keys())
	var configs_ordered = []
	for key in config_strings:
		configs_ordered.append(self.config[key])
	self.apply_config_rules(configs_ordered)

## function that handles the changing of values. [br] Can be modified in different InputManagers
func apply_config_rules(configs_ordered: Array):
	var final_config = {}
	for config in configs_ordered:
		Helper.dictionary_merge_deep(final_config, config.duplicate(true), true)
	
	Helper.apply_dict_values_object(self, final_config.duplicate(true))
	
	set_input_disabled(disable_editing)
	if default_value and typeof(default_value) in GlobalCollections.AcceptedTypes and not has_been_saved:
		receive_input(default_value)
	
	if hide_input:
		self.visible = false
	
	return final_config

## sets the labels and vars for a given property, is used in non array inputs
func set_property_information(property: Dictionary):
	self.property = property
	name_label.text = property["name"]
	input_type = property["type"]

func show_input_warning(error: InputError= null,mute_warnings=false):
	if mute_warnings:
		return
	material.set_shader_parameter("error_color", error_color)
	material.set_shader_parameter("active", true)
	emit_signal("error_occurred", self)
	if error:
		var message = error.create_error_tooltip()
		if message:
			tooltip_text = message

func hide_input_warning():
	tooltip_text = tooltip_string
	if material and material is ShaderMaterial:
		material.set_shader_parameter("active", false)


## virtual function that should be used so each input type can receive input when created
## primarily useful when we're dealing with editing objects instead of creating them
func receive_input(input):
	pass

## virtual function that dis-/enables the input [br]
## mainly used during set up when the class config rules are applied
func set_input_disabled(is_disabled: bool):
	pass

func return_empty_value(error_object: InputError = null):
	if error_object == null:
		error_object = InputError.new_error_object()

	if accept_empty:
		if change_empty_default:
			return TypeManager.find_type_value(input_type, TypeManager.TypeValue.EMPTY_VALUE)
		else:
			error_object.toggle_error("IGNORE", true)
			return error_object
	else:
		error_object.toggle_error("EMPTY", true)
		return error_object

func toggle_focus_shadow():
	var style_box = get_theme_stylebox("panel").duplicate()
	if style_box.shadow_size:
		style_box.shadow_size = 0
	else:
		style_box.shadow_color = Color(207, 255, 253)
		style_box.shadow_size = 1
	add_theme_stylebox_override("panel", style_box)


func set_indent_color():
	if indent_level != 0:
		var stylebox_indent_index = (indent_level - 1) % indent_panel_resources.size()
		var fitting_stylebox = indent_panel_resources[stylebox_indent_index]
		fitting_stylebox = load(fitting_stylebox)
		if fitting_stylebox is StyleBox:
			add_theme_stylebox_override("panel", fitting_stylebox)
		else:
			Helper.throw_error("Stylebox Path for Input is broken")

func _on_input_focus_changed():
	toggle_focus_shadow()
	pass
