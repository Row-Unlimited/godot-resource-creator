@tool
extends Node
## Main plugin class, creates and manages UI Windows and oversees process of object creation

var classLoader
var pluginConfig = preload("res://addons/object_creator/PluginConfig.tres")
var classChoiceScreen = preload("res://addons/object_creator/Scenes/class_choice.tscn")
var createObjectScreen = preload("res://addons/object_creator/Scenes/create_object.tscn")
var pathChoiceScreen = preload("res://addons/object_creator/Scenes/path_choice.tscn")
var navigator = preload("res://addons/object_creator/Scenes/navigator.tscn")
var currentWindow: Control

var isClassChoiceNeeded = true;
var possibleClassObjects: Array
var objectClass = null

var useResourceFormat = false

var finalObject
var path: String

var externalCreationHandler: Object = null
var externalHandlingMethodName: String = ""

signal creation_finished(object, path: String, exportAsResource: bool)

func _ready():
	classLoader = $ClassLoader

## checks the status of the plugin
## if the plugin is integrated it will directly only include named classes
## if not it will search through the entire project structure for classes
## if there is one single possible class it calls the creation screen else it calls the class choice window
func start_creation_process():
	if classLoader.check_for_integration():
		var classes: Array = classLoader.return_integrated_classes()
		match classes.size():
			0:
				pass
			1:
				isClassChoiceNeeded = false
				objectClass = classes.front()
			_:
				possibleClassObjects = classes
		pass
	
	if isClassChoiceNeeded:
		possibleClassObjects = classLoader.return_possible_classes()
		if possibleClassObjects.size() == 1:
			objectClass = possibleClassObjects.front()
			isClassChoiceNeeded = false
	
	if isClassChoiceNeeded:
		call_class_choice_window(possibleClassObjects)
	else:
		call_create_object_window()

## wraps up the object creation process.
## per default it just exports the object and is done, but this can be modified for integration
func finish_creation_process():
	emit_signal("creation_finished", finalObject, path, useResourceFormat)
	Exporter.new(path, [finalObject])
	reset_process()
	

## takes an array of class objects and initiates the class choice window
func call_class_choice_window(classes: Array):
	var classObjects: Array
	var classObject
	for cObject in classes:
		classObject = pluginConfig.contains(cObject)
		if classObject == null:
			classObjects.append(cObject)
			
		else:
			classObjects.append(classObject)
	open_new_window(classChoiceScreen.instantiate())
	currentWindow.create_class_buttons(classObjects)

func call_create_object_window():
	open_new_window(createObjectScreen.instantiate())
	currentWindow.initialize_UI(objectClass)
	if pluginConfig.setExportPath.is_empty():
		currentWindow.connect("object_created", Callable(self, "on_object_created_default"))
	else:
			currentWindow.connect("object_created", Callable(self, "on_object_created_integrated_path"))
			if externalCreationHandler != null:
				currentWindow.connect("object_created", Callable(externalCreationHandler, externalHandlingMethodName))

func set_external_creation_handler(object: Object, methodName: String):
	if object != null and not methodName.is_empty():
		externalCreationHandler = object
		externalHandlingMethodName = methodName

func open_new_window(windowRoot: Control):
	if currentWindow != null:
		remove_child(currentWindow)
	currentWindow = windowRoot
	add_child(windowRoot)

func reset_process():
	if currentWindow != null:
		remove_child(currentWindow)
		currentWindow = null
	start_creation_process()
	finalObject = null
	

func on_class_chosen(cObject):
	objectClass = cObject
	call_create_object_window()

func on_object_created_default(object):
	finalObject = object
	open_new_window(pathChoiceScreen.instantiate())
	currentWindow.initialize_UI(pluginConfig)
	currentWindow.connect("path_chosen", Callable(self, "on_path_chosen"))

func on_object_created_integrated_path(object):
	path = pluginConfig.setExportPath
	finish_creation_process()

func on_path_chosen(pathString: String):
	path = pathString
	finish_creation_process()
