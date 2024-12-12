@tool
class_name TreeExportView
extends Tree

signal edit_item_clicked(item_id)
signal reset_clicked
signal delete_object_clicked(item_id)

enum ButtonType {
	EDIT,
	REFRESH,
	DELETE,
}

var tree_items: Array[TreeItem]
var root_item: TreeItem

## the item whose path is currently being edited
var edit_path_item: TreeItem

var temp_child_wrappers: Array = []
var child_ids: Array = []

#region UiVars
var default_color = Color(1, 1, 1)
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = 3
	_create_base_nodes()
	connect("item_activated", Callable(self, "_on_item_activated"))
	connect("button_clicked", Callable(self, "_handle_button_press"))

func _create_base_nodes():
	root_item = create_item()
	root_item.set_text(0, "GdScript Items")
	var column_titles = [
		"Created Items:",
		"Export Paths:"
	]
	for i in columns:
		if i < column_titles.size():
			set_column_title(i, column_titles[i])
			set_column_title_alignment(i, 0)
	column_titles_visible = true

	set_column_expand_ratio(2, 1.5)

func add_new_object(object_wrapper, path_editable = true):
	if get_item_by_id(object_wrapper.id):
		return

	var parent_item
	var new_item
	if object_wrapper.parent_wrapper:
		parent_item = get_item_by_id(object_wrapper.parent_wrapper.id)
		child_ids.append(object_wrapper.id)
		if parent_item == null:
			temp_child_wrappers.append(object_wrapper)
			return
		new_item = parent_item.create_child()
	else:
		new_item = create_item()
	# save the object_wrapper of the child object until the parent item is saved
	

	new_item.set_metadata(0, object_wrapper.id)
	new_item.set_text(0, object_wrapper.file_class_name)
	new_item.set_text(1, object_wrapper.export_path)
	
	if path_editable:
		new_item.add_button(1, load("res://addons/object_creator/Assets/textures/edit_button.png"))
		new_item.set_metadata(1, ButtonType.EDIT)

	#TODO: implement delete for sub_objects as well
	if parent_item == null:
		new_item.add_button(columns - 1, load("res://addons/object_creator/Assets/textures/Cross.png"))
		new_item.set_metadata(columns - 1, ButtonType.DELETE)

		new_item.set_cell_mode(columns - 1, 1)

	tree_items.append(new_item)

	var children = temp_child_wrappers.filter(func(x): return x.parent_wrapper.id == object_wrapper.id)
	for child in children:
		add_new_object(child, false)

func reset_export_view(wrappers: Array[ObjectWrapper]):
	for item in tree_items:
		item.free()
	tree_items.clear()
	edit_path_item = null

	for wrapper in wrappers:
		add_new_object(wrapper)


## creates dict that links wrapper id to an export path
## does not check if a path exists or is correct
func submit_wrapper_paths():
	var path_dict = {}
	for item: TreeItem in tree_items:
		var item_id = item.get_metadata(0)
		if item_id in child_ids:
			continue
		path_dict[item_id] = item.get_text(1)
	return path_dict

func get_item_by_id(id, column_index = 0):
	var item_as_list = tree_items.filter(func(x:TreeItem): return x.get_metadata(column_index) == id)
	return item_as_list.pop_back() if item_as_list else null

## emits signal with clicked id when an item name column is double clicked
func _on_item_activated():
	var item_id = str(get_selected().get_metadata(get_selected_column()))
	if get_item_by_id(item_id):
		emit_signal("edit_item_clicked", item_id)

func _handle_button_press(item, column, id, mouse_button_index):
	match item.get_metadata(column):
		ButtonType.EDIT:
			item.set_editable(1, true)
			edit_path_item = item
		ButtonType.REFRESH:
			emit_signal("reset_clicked")
		ButtonType.DELETE:
			var item_id = item.get_metadata(0)
			emit_signal("delete_object_clicked", item_id)


## sets the color of all items with id in [param item_ids] to [param color] [br]
## [param change_others_default] makes it so that all ids that are not in [param item_ids]
## are changed back to default [br]
## [param color_columns] defines which columns are changed. by default it will be all.
func set_color_items(item_ids: Array, color: Color, change_others_default = false, color_columns: Array = []):
	for item in tree_items:
		var item_id = item.get_metadata(0)
		if item_id in item_ids or change_others_default:
			var new_color = color if item_id in item_ids else default_color
			for i in columns:
				if i in color_columns or color_columns.is_empty():
					item.set_custom_color(i, new_color)
