class_name UiHelper
extends Object


## takes a [param parent_node] as an argument and goes through all of its children to decrease their size if they are larger than the parent. [br]
## also automatically adjusts the size to fit with the anchors, and position [br]
## only adjusts the x values for now
static func readjust_oversized_children(parent_node: Control):
	var parent_size = parent_node.size
	for child in parent_node.get_children():
		if child.size.x > parent_size.x:
			var anchor_min = clampf(child.anchor_left, 0, 1)
			var anchor_max = clampf(child.anchor_right, 0, 1)
			var horizontal_scale = anchor_max - anchor_min
			child.size.x = parent_size.x * horizontal_scale

			var x_pos = 0
			# readjust position
			if anchor_min > 0:
				x_pos = child.size.x * anchor_min
			
			child.position.x = x_pos

static func control_container_adjust(adjust_node: Control, max_values: Vector2 = Vector2(0, 0)):

	pass

## recursive function that goes through the tree and checks for custom_minimum_size or actual size values to calculate what the minimum size for root node is. [br]
## mostly useful for control nodes that are used within containers
static func find_min_size(node: Control):
	
	pass
