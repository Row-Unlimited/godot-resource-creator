@tool
class_name ArrayElementInput
extends VBoxContainer
## This Class is used in the array_element_input scene to handle UI of Array Inputs
## sets up the InputManager as childObject and updates the array_position of InputManager
## sends signals for movement and removing to the Array_inputManager above

var key_line_edit : LineEdit
var button_container : HBoxContainer

var position_child : int : 
	set(value):
		position_child = value
# this is needed so when we move UI for input, the inputManagers are also moved in the array
		if input:
			input.array_position = value - 1
var input: InputManager

signal move_node(node:ArrayElementInput, isUpwards: int)
signal remove_node(node:ArrayElementInput)

func initialize_input(input: InputManager):
	add_child(input)
	self.input = input
	input.set_up_nodes()
	input.array_position = position_child - 1 # to make sure input has a position

func _on_move_up_pressed():
	emit_signal("move_node", self, position_child - 1)


func _on_move_down_pressed():
	emit_signal("move_node", self, position_child + 1)


func _on_remove_button_pressed():
	emit_signal("remove_node", self)

func add_key_lineEdit():
	button_container = get_node("ButtonContainer")
	key_line_edit = LineEdit.new()
	key_line_edit.placeholder_text = "Key"
	button_container.add_child(key_line_edit)
	button_container.move_child(key_line_edit, 0)
	key_line_edit.size_flags_horizontal = Control.SIZE_EXPAND
