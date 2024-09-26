@tool
class_name TreeExportView
extends Tree

signal edit_item_clicked(item_id)

var root_item: TreeItem

var tree_items: Array[TreeItem]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = 2
	_create_base_nodes()
	connect("item_activated", Callable(self, "_on_item_activated"))

func _create_base_nodes():
	var new_item = self.create_item()
	new_item.set_text(0, "Created Objects:")
	new_item.add_button(1, load("res://addons/object_creator/Assets/refresh.png"))
	new_item.set_metadata(0, "BASE_ITEM")
	root_item = new_item

func add_new_object(obj_dict: Dictionary, path_editable = true):
	var parent_id = obj_dict["parent_id"]; var id = obj_dict["id"]
	var obj_name = obj_dict["name"]; var export_path = obj_dict["export_path"]

	var parent_item = get_item_by_id(parent_id)
	parent_item = parent_item if parent_item and parent_id else root_item

	var new_item = parent_item.create_child()
	new_item.set_text(0, obj_name)
	new_item.set_text(0, export_path)
	new_item.add_button(1, load("res://addons/object_creator/Assets/edit_button.png"))


func get_item_by_id(id, column_index = 0):
	var item_as_list = tree_items.filter(func(x:TreeItem): return x.get_metadata(column_index) == id)
	return item_as_list.pop_back() if item_as_list else null

## emits signal with clicked id when an item name column is double clicked
func _on_item_activated():
	var item_id = get_selected().get_metadata(get_selected_column())
	if item_id != root_item.get_metadata(0) and item_id:
		emit_signal("edit_item_clicked", item_id)
