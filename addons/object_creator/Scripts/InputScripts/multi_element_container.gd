@tool
class_name MultiElementContainer
extends Container
## This Class is used in the multi_element_container scene to handle UI of Array Inputs
## sets up the InputManager as childObject and updates the array_position of InputManager
## sends signals for movement and removing to the Array_inputManager above

const INDENT_UNIT = 30

var key_line_edit : LineEdit
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
@onready var indent_container: Container = $IndentContainer

signal move_node(node : MultiElementContainer, isUpwards: int)
signal remove_node(node : MultiElementContainer)

func initialize_input(input: InputManager):
	if not indent_container:
		indent_container = get_node("IndentContainer")
	button_container = indent_container.get_node("ButtonContainer")
	input_manager = input
	indent_container.add_child(input)
	indent_container.move_child(input, 0)
	self.input = input
	input.initialize_input({})
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
		var buttons = button_container.get_children().filter(func(x): return x is Button)
		for button in buttons:
			button.disabled = disabled_for_user

func _on_move_up_pressed():
	emit_signal("move_node", self, position_child - 1)


func _on_move_down_pressed():
	emit_signal("move_node", self, position_child + 1)


func _on_remove_button_pressed():
	emit_signal("remove_node", self)

func add_key_lineEdit():
	key_line_edit = LineEdit.new()
	key_line_edit.custom_minimum_size.x = 100
	key_line_edit.placeholder_text = "Key"
	button_container.add_child(key_line_edit)
	button_container.move_child(key_line_edit, 0)
	key_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_line_edit.size_flags_stretch_ratio = 1

## removes the move buttons since we don't need them for dictionaries
func remove_move_buttons():
	for button in [button_container.get_node("MoveDownButton"), button_container.get_node("MoveUpButton")]:
		button.visible = false
