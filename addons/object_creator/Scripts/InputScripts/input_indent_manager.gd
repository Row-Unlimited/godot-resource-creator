class_name InputIndentManager
extends GridContainer

const INDENT_MIN_SIZE = 35

var indent_level = 1 : 
	set(value) :
		indent_level = value
		update_margin(indent_level)

@onready var margin_container: MarginContainer = get_node("MarginContainer")

func _ready() -> void:
	var parent = get_parent()
	var new_indent_level
	while parent:
		new_indent_level = parent.get("indent_level")
		if new_indent_level:
			indent_level = new_indent_level
			break
		else:
			parent = parent.get_parent()

func update_margin(i_level: int = indent_level):
	var margin_containers = get_children().filter(func(x): return x is MarginContainer)
	for container in margin_containers:
		if container:
			container.custom_minimum_size.x = indent_level * INDENT_MIN_SIZE

func add_to_manager(node: Control):
	var count = get_child_count()
	var items_per_row = columns
	if count % columns == 0:
		add_child(MarginContainer.new())
		add_child(node)
		update_margin()

func move_custom(node, position):
	if margin_container:
		move_child(node, position + 1)
	else:
		move_child(node, position)
