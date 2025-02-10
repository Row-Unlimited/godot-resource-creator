@tool
class_name ScaleAssistant
extends Node

@export var scale_node: Control :
	set(value):
		scale_node = value
		_ready()
## defines how many levels down the node tree are included in the scaling [br]
## setting it to zero will scale only the node itself 
@export var tree_levels: int
@export var exclude_names: Array[String]
@export var exclude_types: Array[String]

@export var font_size_min: int = 1

var scaling_nodes: Array[Control]
var scaling_nodes_dicts: Array[Dictionary] = []

func _ready():
	if scale_node:
		scaling_nodes = fetch_relevant_nodes(scale_node)
		scale_node.connect("resized", _on_node_resized)
		scaling_nodes_dicts.append_array(scaling_nodes.map(
			func(x):
				var node_dict = {}
				node_dict["node"] = x
				node_dict["initial_size"] = x.size
				if x is Label:
					node_dict["initial_font_size"] = x.get_theme_font_size("font_size")
				return node_dict))
		print(scaling_nodes.map(func(x): return [x.size, x.name]))

func fetch_relevant_nodes(current_node: Control, current_level: int = 0):
	var nodes: Array[Control] = [current_node]
	if current_level != tree_levels:
		for child in current_node.get_children():
			nodes.append_array(fetch_relevant_nodes(child, current_level + 1))
	
	return nodes

## Func is connected to scale_node resized signal and starts the main process of this script
func _on_node_resized():
	print(scaling_nodes.map(func(x): return [x.size, x.name]))
	
	for i in scaling_nodes.size():
		var label = scaling_nodes[i]
		if not label is Label:
			continue
		else:
			print(calc_font(label))
			#calculate_font_size(label, scaling_nodes_dicts[i]["initial_font_size"], font_size_min)
			print("+++++++++++++++++++++++++++++++++++++++++++++++")

func calculate_font_size(node, initial_font_size, min_font_size):
	var font_size = node.get_theme_font_size("font_size")
	print(font_size)
	print(initial_font_size)
	var text_size_x = node.get_character_bounds(node.get_total_character_count() - 1)
	text_size_x = text_size_x.position.x + text_size_x.size.x
	if node.get_line_count() <= node.get_visible_line_count() and node.size.x > text_size_x:
		if font_size >= initial_font_size:
			return initial_font_size
		else:
			node.add_theme_font_size_override("font_size", font_size + 1)
			font_size = calculate_font_size(node, initial_font_size, min_font_size)
			node.add_theme_font_size_override("font_size", font_size)
			return font_size
		pass
	else:
		if font_size <= min_font_size:
			print("huh?")
			node.add_theme_font_size_override("font_size", 1)
			return min_font_size
		else:
			node.add_theme_font_size_override("font_size", font_size - 1)
			font_size = calculate_font_size(node, initial_font_size - 1, min_font_size)
			#node.add_theme_font_size_override("font_size", font_size)
			return font_size

func calc_font(label):
	var font_size = label.get_theme_font_size("font_size")
	var text_size_x = label.get_character_bounds(label.get_total_character_count() - 1)
	text_size_x = text_size_x.position.x + text_size_x.size.x
	var sizes_old = []
	var sizes_new = []
	var font = label.get_theme_font("font")
	
	for i in label.text.length():
		var char_size = font.get_string_size(label.text[i], 0, -1, font_size)
		sizes_old.append(char_size.x)
		sizes_new.append(font.get_string_size(label.text[i], 0, -1, font_size - 1).x)
	
	print(text_size_x)
	if font:
		var smaller_font = font.duplicate()  # Duplicate to avoid modifying the original
	
		print(smaller_font.get_multiline_string_size(label.text, 0, -1, font_size - 1))
