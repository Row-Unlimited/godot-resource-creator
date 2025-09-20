@tool
class_name CreationManager
extends Node

const PLUGIN_CONFIG_PATH = "res://addons/object_creator/PluginConfig.tres"
const SETTINGS_CLASS_PATH = "res://addons/object_creator/Scripts/plugin_config.gd"
const CREATE_OBJECT_SCREEN = preload("res://addons/object_creator/Scenes/create_object.tscn")

var class_loader: ClassLoader
var exporter: Exporter

var main_screen_node: Control
# variables for the default scene
var class_tree: TreeClassView
var export_tree: TreeExportView
var class_tree_mapping: Dictionary

var settings_button: TextureButton
var settings_menu: ObjectWrapper

var created_object_wrappers: Array[ObjectWrapper]
var object_counter = 0

## Plugin config loads the PluginConfig.tres resource which is used to store user settings
var plugin_config: PluginConfig
var default_export_path = ""

#region popup_variables
const popup_scene = preload("res://addons/object_creator/Scenes/UI Addon Scenes/popup.tscn")
enum PopupTypes {
	RELOAD,
	DELETE_OBJECT,
}

var text_popups = {
	PopupTypes.RELOAD: ["Plugin reload warning", "Are you sure you want to reload the plugin instance? This will delete everything you have created so far.\nConsider Exporting first."],
	PopupTypes.DELETE_OBJECT: ["Object delete warning", "Are you sure you want to delete this object?"]
}

#endregion

@onready var tab_manager: TabManager = get_node("TabManager")
@onready var main_screen: ScreenManager = get_node("TabManager/MainScreen")
@onready var overview_menu: OverviewMenu = get_node("TabManager/MainScreen/OverviewMenu")
@onready var menu_side_bar: Control = get_node("MenuSideBar")

signal reload_plugin

func _ready() -> void:
	# set up class loader and Exporter
	class_loader = ClassLoader.new()
	add_child(class_loader)
	exporter = Exporter.new()
	add_child(exporter)

	# set up base UI variables
	tab_manager.connect("tab_closed", _on_tab_closed)
	menu_side_bar.get_node("ObjectOverviewButton").connect("pressed", _on_overview_button_pressed)
	menu_side_bar.get_node("RefreshButton").connect("pressed", _on_plugin_refresh_clicked)
	menu_side_bar.get_node("SettingsButton").activate_button(_on_settings_button_pressed)

	# set up config
	plugin_config = load("res://addons/object_creator/PluginConfig.tres")
	default_export_path = plugin_config.set_exportPath if plugin_config.set_exportPath else default_export_path
	# check if user wants to overwrite default scene
	if plugin_config.override_default_scene and load(plugin_config.override_default_scene) is PackedScene:
		var custom_default_node = load(plugin_config.override_default_scene).instantiate()
		if custom_default_node is Control:
			main_screen_node = custom_default_node
		else:
			Helper.throw_error("custom scene is not of type Control")

	if not main_screen_node:
		main_screen_node = overview_menu # assign default menu to main_screen_node if it's empty
		default_scene_setup()

	main_screen.default_node = main_screen_node
	_on_overview_button_pressed()

## connects signals and sets variables if the default scene is used
func default_scene_setup():
	# sets up signals for the main_screen_node, for exporting
	main_screen_node.connect("export_activated", _on_export_activated)

	# set up class_tree for starting new creation processes
	class_tree = main_screen_node.get_node("CreateObjectMenu/TreeClassView")
	class_tree.connect("add_button_clicked", _on_add_item_clicked)
	class_tree.connect("refresh_clicked", _on_tree_refresh_clicked)
	set_up_class_tree()

	# set up export_tree which gives an overview over created objects and lets you edit paths/objects
	export_tree = main_screen_node.get_node("ExportMenu/ExportTree")
	export_tree.connect("edit_item_clicked", _on_obj_edit_clicked)
	export_tree.connect("reset_clicked", _on_export_reset_clicked)
	export_tree.connect("delete_object_clicked", remove_wrapper)

func create_new_creation_screen(object_wrapper: ObjectWrapper, menu_type=CreateObject.CreateMenuType.NORMAL):
	object_wrapper = set_up_new_wrapper(object_wrapper)
	var new_create_window = CREATE_OBJECT_SCREEN.instantiate()
	# give CreateObject callables to connect sub resource input managers to CreationManager
	new_create_window.object_chosen_callable = _on_sub_object_class_chosen
	new_create_window.object_edited_callable = _on_sub_object_edit_clicked
	new_create_window.delete_wrapper_callable = _on_wrapper_removed
	
	new_create_window.initialize_UI(object_wrapper, menu_type)
	tab_manager.create_new_tab(object_wrapper.file_class_name, new_create_window, object_wrapper.id)
	new_create_window.connect("object_created", _on_object_created)
	new_create_window.connect("pre_tab_closed", _on_pre_tab_closed)
	if menu_type != CreateObject.CreateMenuType.NORMAL:
		new_create_window.connect("settings_changed", _on_settings_changed)
	return new_create_window

## loads all creatable classes by searching the project and creates the tree UI
func set_up_class_tree():
	# TODO: maybe export into other script if this base script becomes too big
	var classes = class_loader.return_possible_classes()

	var parent_class_dict = {"gd": {}, "cs": {}}
	var class_counter = 0
	for obj: ObjectWrapper in classes:
		class_counter += 1
		var obj_script: Script = load(obj.path)
		var file_ending = Helper.get_file_ending(obj.path)
		if  file_ending == "gd":
			var filtered_code = Helper.filter_lines(obj_script.source_code, ["extends"])
			var obj_parent_name = Helper.prune_string(filtered_code[0], "extends")
			var obj_id = "objID" + str(class_counter)
			var obj_dict = {"name": obj.file_class_name, "id": obj_id, "object_wrapper": obj, "file_ending": file_ending}
			parent_class_dict["gd"][obj_parent_name] = [obj_dict] if (not obj_parent_name in parent_class_dict["gd"].keys()) else parent_class_dict["gd"][obj_parent_name] + [obj_dict]
			class_tree_mapping[obj_id] = obj
		else:
			# TODO: implement for csharp
			pass
	class_tree.set_up_class_view(parent_class_dict)

func get_wrapper(id):
	var wrapper = created_object_wrappers.filter(func(x): return x.id == id)
	return wrapper[0] if wrapper else null

func set_up_new_wrapper(wrapper: ObjectWrapper):
	if not wrapper.id and not get_wrapper(wrapper.id) in created_object_wrappers:
		wrapper = Helper.duplicate_object(wrapper)
		object_counter += 1
		wrapper.id = str("obj", object_counter)
	
	# maybe usefull else case for integration cases
	return wrapper

func remove_wrapper(id):
	tab_manager.close_tab(id)
	created_object_wrappers = created_object_wrappers.filter(func(x): return x.id != id)
	# filter wrapper from export tree so it doesnt appear there as a child element anymore
	export_tree.temp_child_wrappers = export_tree.temp_child_wrappers.filter(func(x): return x.id != id) 
	export_tree.reset_export_view(created_object_wrappers)

func open_popup(type: PopupTypes):
	var new_popup = popup_scene.instantiate()
	var popup_texts
	if type in text_popups.keys():
		popup_texts = text_popups[type]
	else:
		Helper.throw_error("unregistered popup type")
		return
	
	new_popup.set_text_vars(popup_texts[0], popup_texts[1])
	add_child(new_popup)
	new_popup.connect("popup_cancel", close_popup)
	return new_popup

func close_popup(popup):
	popup.queue_free()

#region signal_functions

func _on_settings_button_pressed():
	if not settings_menu:
		var settings_object: ObjectWrapper = ObjectWrapper.new(SETTINGS_CLASS_PATH, "PluginConfig", plugin_config)
		settings_object = create_new_creation_screen(settings_object, CreateObject.CreateMenuType.SETTINGS).object_wrapper
		settings_menu = settings_object
		tab_manager.select_tab()
	else:
		var current_tab_id = tab_manager.current_node_id
		if current_tab_id and current_tab_id  != settings_menu.id:
			tab_manager.open_tab_by_id(settings_menu.id)
		else:
			_on_overview_button_pressed()

func _on_settings_changed(plugin_config_object: Object):
	if plugin_config_object is ObjectWrapper:
		var new_config = exporter.save_settings_file(plugin_config_object, plugin_config)
		if new_config != null:
			plugin_config = new_config
		else:
			Helper.throw_error("new config is null after saving")
	else:
		Helper.throw_error("plugin_config was delivered to settings change without wrapper")
	
	
	_on_overview_button_pressed()
	tab_manager.close_tab(plugin_config_object.id)

func _on_tree_refresh_clicked():
	class_tree_mapping.clear()
	class_tree.reset_tree()
	set_up_class_tree()

func _on_add_item_clicked(class_id, open_new_window: bool):
	create_new_creation_screen(class_tree_mapping[class_id])
	if open_new_window:
		tab_manager.select_new_tab()

func _on_overview_button_pressed():
	tab_manager.current_node_id = "main"
	main_screen.set_active_node(main_screen_node)
	tab_manager.deselect_tab()

func _on_tab_closed(id):
	var wrapper = get_wrapper(id)
	if wrapper:
		pass
	else:
		tab_manager.delete_object(id)

func _on_pre_tab_closed(node: TabScreen):
	if node.menu_type == CreateObject.CreateMenuType.SETTINGS:
		if settings_menu in created_object_wrappers:
			created_object_wrappers.remove_at(created_object_wrappers.find(settings_menu))
		export_tree.reset_export_view(created_object_wrappers)
		settings_menu = null


func _on_object_created(object_wrapper: ObjectWrapper):
	if object_wrapper.parent_wrapper == null:
		object_wrapper.export_path = default_export_path if object_wrapper.export_path.is_empty() else object_wrapper.export_path
	else:
		var parent_wrapper = get_wrapper(object_wrapper.parent_wrapper.id)
		if parent_wrapper:
			parent_wrapper.child_wrapper_ids.append(object_wrapper.id)
	var get_wrapper_duplicate = get_wrapper(object_wrapper.id)
	if  get_wrapper_duplicate == null:
		created_object_wrappers.append(object_wrapper)
	else:
		created_object_wrappers.set(created_object_wrappers.find(get_wrapper_duplicate), object_wrapper)
	export_tree.add_new_object(object_wrapper)
	main_screen.set_active_node(main_screen_node)
	tab_manager.close_tab(object_wrapper.id)

func _on_export_activated(path_dict: Dictionary):
	var parent_wrappers = created_object_wrappers.filter(func(x): return x.parent_wrapper == null)
	for wrapper in parent_wrappers:
		wrapper.refresh_obj_with_dict(created_object_wrappers)
		if wrapper.id in path_dict.keys():
			wrapper.export_path = path_dict[wrapper.id]
		else:
			Helper.throw_error("Not all wrappers are in the export path_dict")
	exporter.export_wrappers(parent_wrappers)

func _on_export_reset_clicked():
	export_tree.reset_export_view(created_object_wrappers)

func _on_obj_edit_clicked(obj_id):
	var wrapper = get_wrapper(obj_id)
	create_new_creation_screen(wrapper)

## is called by a signal when in the ObjectInput class the ChooseClassButton is pressed sucessfully.
func _on_sub_object_class_chosen(wrapper: ObjectWrapper, input_manager: ObjectInput):
	if wrapper.id and get_wrapper(wrapper.id) in created_object_wrappers:
		input_manager.chosen_wrapper = wrapper
		return
	
	var new_wrapper = set_up_new_wrapper(wrapper)
	if wrapper.obj:
		new_wrapper.obj = wrapper.obj
	if input_manager.chosen_wrapper.id:
		remove_wrapper(input_manager.chosen_wrapper.id)
	input_manager.chosen_wrapper = new_wrapper

func _on_sub_object_edit_clicked(wrapper: ObjectWrapper, input_manager: ObjectInput):
	if not tab_manager.open_tab_by_id(wrapper.id):
		input_manager.object_create_screen = create_new_creation_screen(wrapper)

func _on_plugin_refresh_clicked():
	var popup = open_popup(PopupTypes.RELOAD)
	popup.connect("popup_continue", func():self.emit_signal("reload_plugin"))

func _on_wrapper_removed(wrapper: ObjectWrapper):
	if wrapper.id:
		remove_wrapper(wrapper.id)

func _on_reload_plugin():
	emit_signal("reload_plugin")

#endregion
