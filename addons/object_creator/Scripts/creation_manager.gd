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
var export_tree: TreeExportView
var class_tree_mapping: Dictionary

var main_screen
var overview_menu: Control
var menu_side_bar: Control

var created_object_dicts: Array[Dictionary]
var object_counter = 0

var default_export_path

func _ready() -> void:
	tab_manager = get_node("TabManager")

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




func create_new_creation_screen(class_object: ClassObject, menu_type=CreateObject.CreateMenuType.NORMAL):
	var new_create_window = create_object_screen.instantiate()
	new_create_window.initialize_UI(class_object)
	tab_manager.create_new_tab(class_object.name_class, new_create_window)
	new_create_window.connect("object_created", Callable(self, "_on_object_created"))
	if menu_type != CreateObject.CreateMenuType.NORMAL:
		new_create_window.connect("settings_changed", Callable(self, "_on_settings_changed"))


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
			class_tree_mapping[obj_id] = obj
		else:
			# TODO: implement for csharp
			pass
	class_tree.set_up_class_view(parent_class_dict)

func _on_tree_refresh_clicked():
	class_tree_mapping.clear()
	class_tree.reset_tree()
	set_up_class_tree()

func _on_add_item_clicked(class_id):
	create_new_creation_screen(class_tree_mapping[class_id])
	pass

func _on_overview_button_pressed():
	main_screen.set_active_node(overview_menu)


func _on_object_created(object: Resource, object_wrapper: ClassObject):
	Helper.print_object_values(object)
	object_counter += 1
	pass

func _on_settings_changed(plugin_config_object: PluginConfig):
	pass
