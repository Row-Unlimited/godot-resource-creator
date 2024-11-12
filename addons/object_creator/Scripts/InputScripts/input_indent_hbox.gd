class_name InputIndentHbox
extends HBoxContainer

const INDENT_MIN_SIZE = 35

var indent_level = 1
var margin_container: MarginContainer

func _ready() -> void:
	var parent = get_parent()
	var new_indent_level
	while parent:
		new_indent_level = parent.get("indent_level")
		if new_indent_level:
			indent_level = new_indent_level
			margin_container = MarginContainer.new()
			add_child(margin_container)
			move_child(margin_container, 0)
			margin_container.custom_minimum_size.x = indent_level * INDENT_MIN_SIZE
			break
		else:
			parent = parent.get_parent()

func move_custom(node, position):
	if margin_container:
		move_child(node, position + 1)
	else:
		move_child(node, position)
