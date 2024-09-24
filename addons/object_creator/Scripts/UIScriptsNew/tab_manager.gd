@tool
class_name TabManager
extends Control

var tab_bar: TabBar
var tab_screen: Control

## counts each created tab, to create unique IDs for every tab
var tab_counter = 0
## dict that maps ids to index
var tab_id_mapping = {}

## Where the user is hovering over. -1 if they are hovering above nothing
var hover_target: int


func _ready() -> void:
	tab_bar = get_node("TabBar")
	tab_screen = get_node("MainScreen")
	tab_bar.connect("tab_selected", Callable(self, "change_tab_screen"))
	# signal is for closing tabs
	tab_bar.connect("tab_hovered", Callable(self, "_on_tab_hovered"))

func create_new_tab(tab_name, tab_node: Control = null) -> int:
	tab_counter += 1
	var tab_index = tab_bar.tab_count

	tab_id_mapping[tab_counter] = {"index": tab_index, "tab_node": tab_node}
	
	tab_bar.add_tab(tab_name)
	tab_bar.set_tab_metadata(tab_index, {"ID": tab_counter})
	return tab_counter

func close_tab(id: int):
	
	pass

func change_tab_screen(index: int):
	var tab_id = get_tab_id(index)
	if tab_id == -1:
		assert(false, "no id for this index")
	else:
		var tab_node = get_tab_node(tab_id)
		tab_screen.set_active_node(tab_node)
		#if tab_node in tab_screen.get_children():
			#tab_node.visible = true 
		#else:
			#tab_screen.add_child(tab_node)
		#
		#for child in tab_screen.get_children():
			##child.visible = false
			#pass
		


func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var mouse_position = get_viewport().get_mouse_position() - self.get_rect().position
		var tab_rect = tab_bar.get_tab_rect(hover_target)
		if tab_rect.has_point(mouse_position):
			close_tab(get_tab_id(hover_target))

func get_tab_id(index: int):
	for key in tab_id_mapping.keys():
		if tab_id_mapping[key]["index"] == index:
			return key
	return -1

func get_tab_index(id: int):
	return tab_id_mapping[id]["index"]

func get_tab_node(id: int):
	return tab_id_mapping[id]["tab_node"]

func _on_tab_hovered(index: int):
	hover_target = index
	
