class_name TreeClassView
extends Tree

signal add_button_clicked(class_id)
signal refresh_clicked

var categories: Array = []

var gd_tree_item: TreeItem
var cs_tree_item: TreeItem

var root_item: TreeItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_base_nodes()
	connect("button_clicked", Callable(self, "_on_button_clicked"))

func _create_base_nodes():
	var new_item = self.create_item()
	new_item.set_text(0, "Creatable classes overview")
	new_item.add_button(0, load("res://addons/object_creator/Assets/refresh.png"))
	new_item.set_metadata(0, "BASE_ITEM")
	root_item = new_item

func set_up_class_view(class_name_dict):
	var gd_dict = class_name_dict["gd"]
	var cs_dict = class_name_dict["cs"]
	if gd_dict.keys():
		var script_type_item = create_item(root_item)
		script_type_item.set_text(0, "GDscript classes:")
		_set_up_view_for_type(gd_dict, script_type_item)
	
	if cs_dict.keys():
		var script_type_item = create_item(root_item)
		script_type_item.set_text(0, "CSharp classes:")
		_set_up_view_for_type(cs_dict, script_type_item)

	
	
	
## sets up the tree view items.
## [param class_name_dict] holds the item information
## [param script_type_item] is the tree item the categories should be put under
func _set_up_view_for_type(class_name_dict: Dictionary, script_type_item):
	for key in class_name_dict.keys():
		var dict_array = class_name_dict[key]
		var new_category = create_item(script_type_item)
		new_category.set_text(0, key + ":")
		categories.append(new_category)

		for obj_dict in dict_array:
			var new_item = create_item(new_category)
			new_item.set_text(0, obj_dict["name"])
			new_item.set_metadata(0, obj_dict["id"])
			new_item.add_button(0, load("res://addons/object_creator/Assets/Plus.png"))


func _on_button_clicked(item, column, id, mouse_button_index):
	var item_id = item.get_metadata(0)
	
	if item_id == "BASE_ITEM":
		emit_signal("refresh_clicked")
	else:
		emit_signal("add_button_clicked", item_id)

func reset_tree():
	self.clear()
	root_item = null
	gd_tree_item = null
	cs_tree_item = null
	_create_base_nodes()
