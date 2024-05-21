@tool
extends Node

var classLoader
var userInformation = preload("res://addons/object_creator/UserInformation.tres")
var classChoiceScreen = preload("res://addons/object_creator/Scenes/class_choice.tscn")
var createObjectScreen = preload("res://addons/object_creator/Scenes/create_object.tscn")
var isClassChoiceNeeded = true;
var possibleClassObjects: Array
var objectClass = null

var finalObject

var currentWindow: Control

func _ready():
	classLoader = $ClassLoader
	check_creation_status()

## checks the status of the plugin
## if the plugin is integrated it will directly only include named classes
## if not it will search through the entire project structure for classes
## if there is one single possible class it calls the creation screen else it calls the class choice window
func check_creation_status():
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

## takes an array of class objects and initiates the class choice window
func call_class_choice_window(classes: Array):
	var classObjects: Array
	var classObject
	for cObject in classes:
		classObject = userInformation.contains(cObject)
		if classObject == null:
			classObjects.append(cObject)
			
		else:
			classObjects.append(classObject)
	open_new_window(classChoiceScreen.instantiate())
	currentWindow.create_class_buttons(classObjects)

func call_create_object_window():
	open_new_window(createObjectScreen.instantiate())
	currentWindow.initialize_UI(objectClass)
	currentWindow.connect("object_created", Callable(self, "on_object_created"))

func call_path_choice_window():
	pass

func open_new_window(windowRoot: Control):
	if currentWindow != null:
		remove_child(currentWindow)
	currentWindow = windowRoot
	add_child(windowRoot)


func on_class_chosen(cObject):
	objectClass = cObject
	call_create_object_window()

func on_object_created(object):
	finalObject = object
	if userInformation.isIntegrated:
		pass
	else:
		call_path_choice_window()
	pass
