@tool
class_name TabManager
extends Control

signal tab_closed(obj_id)

var tab_bar: TabBar
var tab_screen: Control

## counts each created tab, to create unique IDs for every tab
var tab_counter = 0
## dict that maps ids to index and node. [br] Id is the key
var tab_id_mapping: Dictionary = {}

## Where the user is hovering over. -1 if they are hovering above nothing
var hover_target: int

## to make sure users don't accidentally close multiple tabs
var tab_just_closed = false


func _ready() -> void:
	tab_bar = get_node("TabBar")
	tab_screen = get_node("MainScreen")
	tab_bar.connect("tab_selected", Callable(self, "change_tab_screen"))
	# signal is for closing tabs
	tab_bar.connect("tab_hovered", Callable(self, "_on_tab_hovered"))

func create_new_tab(tab_name, tab_node: Control = null, tab_id = "") -> String:
	tab_counter += 1
	var tab_index = tab_bar.tab_count
	tab_id = tab_id if tab_id else str(tab_counter)
	tab_id_mapping[tab_id] = {"index": tab_index, "tab_node": tab_node}
	
	tab_bar.add_tab(tab_name)
	tab_bar.set_tab_metadata(tab_index, {"ID": tab_id})
	return tab_id

## closes a tab and then changes the UI, decreases the indicies after and emits a signal
func close_tab(id):
	if not id in tab_id_mapping.keys():
		return
	var tab_index = get_tab_index(id)
	tab_bar.remove_tab(tab_index)
	if tab_index - 1 >= 0:
		tab_screen.remove_node(get_tab_node(id), get_tab_node(get_tab_id(tab_index - 1)))
	else:
		tab_screen.remove_node(get_tab_node(id))
	
	decrease_index_after(tab_index)
	tab_id_mapping.erase(id)

	emit_signal("tab_closed", id)

func change_tab_screen(index: int):
	var tab_id = get_tab_id(index)
	if not tab_id:
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

func open_tab_by_id(id) -> bool:
	var index = get_tab_index(id)
	if index != null:
		change_tab_screen(index)
		return true
	else:
		return false

func delete_object(id):
	tab_id_mapping.erase(id)

## decreases the index of all current tabs after the index[br]
## is used when a tab is deleted so all tabs after that tab get the correct index
func decrease_index_after(index):
	for key in tab_id_mapping.keys():
		if tab_id_mapping[key]["index"] > index:
			tab_id_mapping[key]["index"] -= 1

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var mouse_position = get_viewport().get_mouse_position() - self.get_rect().position
		if not tab_bar.tab_count:
			return
		var tab_rect = tab_bar.get_tab_rect(hover_target)
		if tab_rect.has_point(mouse_position) and tab_just_closed == false:
			close_tab(get_tab_id(hover_target))
			tab_just_closed = true
	else:
		tab_just_closed = false

func get_tab_id(index: int):
	for key in tab_id_mapping.keys():
		if tab_id_mapping[key]["index"] == index:
			return key
	return ""

func get_tab_index(id: String):
	if id in tab_id_mapping.keys():
		return tab_id_mapping[id]["index"]
	else:
		return null

func get_tab_node(id: String):
	return tab_id_mapping[id]["tab_node"]

func _on_tab_hovered(index: int):
	hover_target = index
	
