@tool
class_name ScreenManager
extends Control

var default_node: Control

func _ready() -> void:
	pass

func set_active_node(active_node: Control, overide_active = true):
	var children = get_children()
	if active_node in children:
		active_node.visible = true
		children.erase(active_node)
	else:
		add_child(active_node)
	
	if overide_active:
		for child in children:
			child.visible = false
	pass

## checks if given node is currently active [br] If not it will do nothing [br]
## if yes it will remove it and switch to a different one
func remove_node(remove_node, switch_node = default_node):
	var children = get_children()

	if remove_node in children:
		set_active_node(switch_node)
