@tool
class_name ScaleAssistant
extends Node

const included_types: Array = ["Button", "Label", "LineEdit"]

@export var scale_node: Control :
	set(value):
		scale_node = value
		if node_active_start:
			begin_scale_process()
## defines how many levels down the node tree are included in the scaling [br]
## setting it to zero will do nothing -1 will use all child nodes
@export var tree_levels: int = -1
@export var exclude_names: Array[String] = []

## margins for the label with NESW. All fields have to be filled.
@export var node_active_start: bool = false :
	set(value):
		if value and started != true:
			begin_scale_process()
		node_active_start = value

## defines max size of scale_node for font_calculations.
## Putting in -1 means it takes the initial size of the scale_node
@export var max_size: Vector2 = Vector2(-1, -1)
## will be added onto max_size especially useful when using -1 in max_size
@export var max_size_modifiers: Vector2 = Vector2(0, 0)
@export var font_size_steps: Vector2 = Vector2(150, 100)
## defines how much the default theme font_size is different from the max
## 0 means the font_size cannot become bigger than the default assigned values
@export var default_to_max_distance: int = 0
## defines how many steps in font_size are at max made by this script [br]
## if the default is 16, and this is 6 then no mater how small the window becomes it cannot be smaller than 10 [br]
## if [param default_to_max_distance] is larger 0 like 2, then the font_size can at minimum become 12 since it can also grow beyond the default.
@export var max_font_difference: int

var scaling_nodes: Array[Control]
var scaling_nodes_dicts: Array[Dictionary] = []

var started = false

var current_steps: int = -1

func begin_scale_process():
	if scale_node:
		if scale_node.is_node_ready():
			started = true
			scaling_nodes = fetch_relevant_nodes(scale_node)
			scale_node.connect("resized", _on_node_resized)
			scaling_nodes_dicts.append_array(scaling_nodes.map(
				func(x):
					var node_dict = {}
					node_dict["node"] = x
					node_dict["initial_size"] = x.size
					if x is Label and x.label_settings:
						node_dict["max_font_size"] = x.label_settings.font_size + default_to_max_distance
					else:
						node_dict["max_font_size"] = x.get_theme_font_size("font_size") + default_to_max_distance
					return node_dict))
			_on_node_resized()
		else:
			scale_node.connect("ready", _on_scale_node_ready)


func fetch_relevant_nodes(current_node, current_level: int = 0):
	var nodes: Array[Control] = []
	if current_level < tree_levels or tree_levels == -1:
		var children = current_node.get_children()
		var valid_children = children.filter(func(child):
			var conditions = []
			conditions.append(not exclude_names.any(func(y): return y in child.name))
			conditions.append(child is Control)
			conditions.append(included_types.any(func(z): return child.is_class(z)))
			conditions.append(child.has_method("get_theme_font_size") and child.has_method("add_theme_font_size_override"))
			return conditions.all(func(y): return y))
		
		for child in children:
			nodes.append_array(fetch_relevant_nodes(child, current_level + 1))


		for child in valid_children:
			if not exclude_names.any(func(x): return x in child.name):
				nodes.append(child)
				nodes.append_array(fetch_relevant_nodes(child, current_level + 1))
	return nodes

func calc_current_steps():
	var scale_node_size = scale_node.size
	var steps_max: int
	if scale_node_size.x + font_size_steps.x > max_size.x and scale_node_size.y + font_size_steps.y > max_size.y:
		steps_max = 0
	else:
		var step_size_max = max_size / font_size_steps
		var step_size_current = scale_node_size / font_size_steps
		step_size_current = floor(step_size_max - step_size_current)
		steps_max = max(step_size_current.x, step_size_current.y)
	steps_max = min(steps_max, max_font_difference)
	return steps_max

## Func is connected to scale_node resized signal and starts the main process of this script
func _on_node_resized():
	var new_step_count = calc_current_steps()
	if new_step_count == current_steps:
		return
	else:
		current_steps = new_step_count

	#resize all font_sizes
	for i in scaling_nodes.size():
		var node = scaling_nodes[i]
		var dict = scaling_nodes_dicts[i]
		var new_font_size = dict["max_font_size"] - current_steps
		new_font_size = max(1, new_font_size)
		if node is Label and node.label_settings:
			node.label_settings.font_size = new_font_size
		node.add_theme_font_size_override("font_size", new_font_size)


func _on_scale_node_ready():
	if max_size.x == -1:
		max_size.x = scale_node.size.x
	if max_size.y == -1:
		max_size.y = scale_node.size.y
	max_size.x += max_size_modifiers.x
	max_size.y += max_size_modifiers.y
	begin_scale_process()
