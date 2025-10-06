@tool
class_name MultiElementContainer
extends Container
## This Class is used in the multi_element_container scene to handle UI of Array Inputs
## sets up the InputManager as childObject and updates the array_position of InputManager
## sends signals for movement and removing to the Array_inputManager above

const INDENT_UNIT = 30
const KEY_INPUT_SCENE = preload("res://addons/object_creator/Scenes/Variable Input Scenes/dict_key_input.tscn")

var key_node
var key_node_open_button: Button
var key_line_edit : LineEdit
var key_is_line_edit: bool = true
var key_type: Variant.Type
var key_object_type: String ## name of the object if key is typed object
var dict_string_default: bool

var button_container : HBoxContainer

var input_manager : InputManager

var position_child : int : 
	set(value):
		position_child = value
		# this is needed so when we move UI for input, the inputManagers are also moved in the array
		if input:
			input.array_position = value - 1
var input: InputManager

var disabled_for_user: bool = false :
	set(value):
		disabled_for_user = value
		if ready:
			disable_buttons()

var indent_level = 1 :
	set(value):
		indent_level = value
		add_theme_constant_override("margin_left", INDENT_UNIT)
@onready var indent_container: Container = $KeyInputContainer/IndentContainer
@onready var key_input_container: VBoxContainer = $KeyInputContainer

signal move_node(node : MultiElementContainer, isUpwards: int)
signal remove_node(node : MultiElementContainer)

func initialize_input(input: InputManager):
	if not indent_container:
		indent_container = get_node("KeyInputContainer/IndentContainer")
	button_container = indent_container.get_node("ButtonContainer")
	input_manager = input
	input.initialize_input({})
	indent_container.add_child(input)
	indent_container.move_child(input, 0)
	self.input = input
	input.array_position = position_child - 1 # to make sure input has a position
	disable_buttons()

func calc_minimum_size():
	var size = 0
	if button_container:
		size += button_container.size.y
	if input_manager:
		size += input_manager.calc_minimum_size()
	return size

func disable_buttons():
	if button_container and button_container.get_children():
		var buttons = button_container.get_children().filter(func(x): return x is TextureButton)
		for button in buttons:
			button.disabled = disabled_for_user

func set_key_disable(disable_status: bool):
	if key_is_line_edit:
		key_line_edit.editable = disable_status

func get_key():
	if key_is_line_edit:
		return key_line_edit.text
	else:
		return key_node.attempt_submit()


func set_key(key):
	if key_is_line_edit:
		key_line_edit.text = key


func add_key_lineEdit(key_typed: Variant.Type = 0, key_object_name = ""):
	if key_type == 0 and dict_string_default:
		key_line_edit = LineEdit.new()
		key_line_edit.custom_minimum_size.x = 100
		key_line_edit.placeholder_text = "Key"
		button_container.add_child(key_line_edit)
		button_container.move_child(key_line_edit, 0)
		key_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		key_line_edit.size_flags_stretch_ratio = 1
	else:
		key_type = key_typed
		key_node_open_button = Button.new()
		key_node_open_button.custom_minimum_size.x = 100
		key_node_open_button.text = "Set Key"
		button_container.add_child(key_node_open_button)
		button_container.move_child(key_node_open_button, 0)
		key_node_open_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		key_node_open_button.size_flags_stretch_ratio = 1
		key_node_open_button.connect("pressed", _on_set_key_pressed)
		key_is_line_edit = false
		key_object_type = key_object_name

func _on_set_key_pressed():
	key_node = KEY_INPUT_SCENE.instantiate()
	key_node.key_type = key_type
	if key_object_type:
		key_node.key_object_type = key_object_type
	key_node_open_button.disabled = true
	key_input_container.add_child(key_node)

func _on_move_up_pressed():
	emit_signal("move_node", self, position_child - 1)


func _on_move_down_pressed():
	emit_signal("move_node", self, position_child + 1)


func _on_remove_button_pressed():
	emit_signal("remove_node", self)

## removes the move buttons since we don't need them for dictionaries
func remove_move_buttons():
	for button in [button_container.get_node("MoveDownButton"), button_container.get_node("MoveUpButton")]:
		button.visible = false
