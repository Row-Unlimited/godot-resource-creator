@tool
class_name CreationManager
extends Node

const PLUGIN_CONFIG_PATH = "res://addons/object_creator/PluginConfig.tres"
const SETTINGS_CLASS_PATH = "res://addons/object_creator/Scripts/plugin_config.gd"

var create_object_screen = preload("res://addons/object_creator/Scenes/create_object.tscn")
var class_choice_screen = preload("res://addons/object_creator/Scenes/class_choice.tscn")

## holds the information for all ongoing create object processes [br]
## example: {class_path:"", export_path:"", process_id:"12", parent_process_id:"1", session_dict:""}
var object_processes: Array[Dictionary]
var tab_manager: TabManager

var class_loader: ClassLoader

var class_tree: TreeClassView
var tree_mapping_dict: Dictionary

var main_screen
var overview_menu: Control
var menu_side_bar: Control

func _ready() -> void:
	tab_manager = get_node("TabManager")
	tab_manager.create_new_tab("test other tab", class_choice_screen.instantiate())

	main_screen = get_node("TabManager/MainScreen")
	overview_menu = get_node("TabManager/MainScreen/OverviewMenu")
	menu_side_bar = get_node("MenuSideBar")

	class_loader = ClassLoader.new()
	add_child(class_loader)

	class_tree = overview_menu.get_node("CreateObjectMenu/TreeClassView")
	class_tree.connect("add_button_clicked", Callable(self, "_on_add_item_clicked"))
	class_tree.connect("refresh_clicked", Callable(self, "_on_tree_refresh_clicked"))
	set_up_class_tree()

	menu_side_bar.get_node("ObjectOverviewButton").connect("pressed", Callable(self, "_on_overview_button_pressed"))




func create_new_object(class_object: ClassObject):
	var new_create_window = create_object_screen.instantiate()
	new_create_window.initialize_UI(class_object)
	tab_manager.create_new_tab("test_tab", new_create_window)

## deletes object process by ID
func delete_object_process(object_id: int):
	pass

## loads all creatable classes by searching the project and creates the tree UI
func set_up_class_tree():
	# TODO: maybe export into other script if this base script becomes too big
	var classes = class_loader.return_possible_classes()

	var parent_class_dict = {"gd": {}, "cs": {}}
	var class_counter = 0
	for obj: ClassObject in classes:
		class_counter += 1
		var obj_script: Script = load(obj.path)
		var file_ending = Helper.get_file_ending(obj.path)
		if  file_ending == "gd":
			var filtered_code = Helper.filter_lines(obj_script.source_code, ["extends"])
			var obj_parent_name = Helper.prune_string(filtered_code[0], "extends")
			var obj_id = "objID" + str(class_counter)
			var obj_dict = {"name": obj.name_class, "id": obj_id, "class_object": obj, "file_ending": file_ending}
			parent_class_dict["gd"][obj_parent_name] = [obj_dict] if (not obj_parent_name in parent_class_dict["gd"].keys()) else parent_class_dict["gd"][obj_parent_name] + [obj_dict]
			tree_mapping_dict[obj_id] = obj
		else:
			# TODO: implement for csharp
			pass
	class_tree.set_up_class_view(parent_class_dict)

func _on_tree_refresh_clicked():
	tree_mapping_dict.clear()
	class_tree.reset_tree()
	set_up_class_tree()

func _on_add_item_clicked(class_id):
	create_new_object(tree_mapping_dict[class_id])
	pass

func _on_overview_button_pressed():
	main_screen.set_active_node(overview_menu)
