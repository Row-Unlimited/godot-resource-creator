extends Control


func _ready() -> void:
	pass

func set_active_node(active_node: Control, overide_active = true):
	print("hello ", active_node)
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