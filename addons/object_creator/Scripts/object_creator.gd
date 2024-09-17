@tool
extends Node
## Main plugin class, creates and manages UI Windows and oversees process of object creation

const PLUGIN_CONFIG_PATH = "res://addons/object_creator/PluginConfig.tres"
const SETTINGS_CLASS_PATH = "res://addons/object_creator/Scripts/plugin_config.gd"

var class_loader : ClassLoader ## Node used to load class information from the project
var exporter : Exporter
var plugin_config #= preload(PLUGIN_CONFIG_PATH)
var class_choiceScreen = preload("res://addons/object_creator/Scenes/class_choice.tscn")
var create_objectScreen = preload("res://addons/object_creator/Scenes/create_object.tscn")
var path_choiceScreen = preload("res://addons/object_creator/Scenes/path_choice.tscn")
var navigator
var settings_button
var current_window: CreationWindow
var window_sessions: Array
var ui_node: Control

var is_settings_menu = false

var is_classChoiceNeeded = true;
var possible_classObjects: Array
var object_class: ClassObject = null

var use_resourceFormat = false

var final_object
var path: String

#region integration_variables
var external_creationHandler: Object = null
var external_handlingMethodName: String = ""
var navigator_callable: Callable
var is_defaultCallableActive = true
#endregion

signal creation_finished(object, path: String, exportAsResource: bool)

func _ready():
	class_loader = $ClassLoader
	ui_node = get_node("UINode")
	navigator = get_node("Navigator")
	settings_button = get_node("Settings-Button")
	exporter = get_node("Exporter")

## checks the status of the plugin
## if the plugin is integrated it will directly only include named classes
## if not it will search through the entire project structure for classes
## if there is one single possible class it calls the creation screen else it calls the class choice window
func start_creation_process():
	window_sessions = []

	plugin_config = ResourceLoader.load(PLUGIN_CONFIG_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	if is_defaultCallableActive:
		navigator_callable = Callable(self, "handle_navigator")
	settings_button.activate_button(Callable(self, "_on_settings_button_pressed"))
	if not navigator.is_connected("navigator_pressed", navigator_callable):
		navigator.connect("navigator_pressed", navigator_callable)
	if class_loader.check_for_integration():
		var classes: Array = class_loader.return_integrated_classes()
		match classes.size():
			0:
				pass
			1:
				is_classChoiceNeeded = false
				object_class = classes.front()
			_:
				possible_classObjects = classes
		pass
	
	if is_classChoiceNeeded:
		possible_classObjects = class_loader.return_possible_classes()
		if possible_classObjects.size() == 1:
			object_class = possible_classObjects.front()
			is_classChoiceNeeded = false
	
	if is_classChoiceNeeded:
		call_class_choice_window(possible_classObjects)
	else:
		call_create_object_window(object_class)

## wraps up the object creation process.
## per default it just exports the object and is done, but this can be modified for integration
func finish_creation_process():
	emit_signal("creation_finished", final_object, path, use_resourceFormat)
	exporter.export_files(path, [final_object])
	plugin_config.update_user_class_information(object_class)
	plugin_config.sort_arrays()
	for cObject in plugin_config.classObjects:
		print(cObject.name_class + " " + cObject.path)
	#ResourceSaver.save(plugin_config, PLUGIN_CONFIG_PATH, )
	reset_process()

func reset_process():
	if current_window != null:
		ui_node.remove_child(current_window)
		current_window = null
	start_creation_process()
	final_object = null

func set_external_creation_handler(object: Object, methodName: String):
	if object != null and not methodName.is_empty():
		external_creationHandler = object
		external_handlingMethodName = methodName

func set_navigator_callable(callable: Callable):
	navigator_callable = callable

#region UI-Handling
func handle_navigator(is_reset: bool):
	if is_reset:
		is_settings_menu = false
		reset_process()
	else:
		navigate_back()

## takes an array of class objects and initiates the class choice window
func call_class_choice_window(classes: Array):
	var classObjects: Array
	var classObject
	for cObject in classes:
		classObject = plugin_config.contains(cObject)
		if classObject == null:
			classObjects.append(cObject)
			
		else:
			classObjects.append(classObject)
	open_new_window(class_choiceScreen.instantiate())
	current_window.create_class_buttons(classObjects, Callable(self, "on_class_chosen"))

func call_create_object_window(cObject: ClassObject, menu_type=CreateObject.CreateMenuType.NORMAL):
	open_new_window(create_objectScreen.instantiate())
	current_window.initialize_UI(cObject, menu_type)
	current_window.connect("settings_changed", Callable(exporter, "save_settings_file"))
	if plugin_config.set_exportPath.is_empty():
		current_window.connect("object_created", Callable(self, "on_object_created_default"))
	else:
			current_window.connect("object_created", Callable(self, "on_object_created_integrated_path"))
			if external_creationHandler != null:
				current_window.connect("object_created", Callable(external_creationHandler, external_handlingMethodName))

func open_new_window(new_window: Control):	
	if current_window != null:
		ui_node.remove_child(current_window)
		if current_window.window_type == CreationWindow.WindowType.CREATE_OBJECT:
			window_sessions.append(current_window.save_session())
	current_window = new_window
	ui_node.add_child(new_window)

func navigate_back():
	if window_sessions:
		var last_session_dict: Dictionary = window_sessions.pop_back()
		call_create_object_window(last_session_dict["class_object"])
		current_window.load_session(last_session_dict)
	pass

#endregion

#region signal functions
func on_class_chosen(cObject):
	object_class = cObject
	call_create_object_window(object_class)

func on_object_created_default(object):
	final_object = object
	open_new_window(path_choiceScreen.instantiate())
	current_window.initialize_UI(plugin_config)
	current_window.connect("path_chosen", Callable(self, "on_path_chosen"))

func on_object_created_integrated_path(object):
	path = plugin_config.set_exportPath
	finish_creation_process()

func on_path_chosen(path_string: String, is_json: bool):
	path = path_string
	finish_creation_process()

func _on_settings_button_pressed():
	if not is_settings_menu:
		var settings_object: ClassObject = ClassObject.new(SETTINGS_CLASS_PATH, "PluginConfig", plugin_config)
		call_create_object_window(settings_object, CreateObject.CreateMenuType.SETTINGS)
		is_settings_menu = true
	else:
		navigate_back()

#endregion
