@tool
extends Control
## UI Window that handles choosing which class to create an Object from

var scrollContainer: ScrollContainer
var flowContainer: GridContainer
const margin = 20
var buttonScene = preload("res://addons/object_creator/Scenes/class_button.tscn")
var resourceClasses: Array


func _ready():
	scrollContainer = get_child(0)
	flowContainer = scrollContainer.get_child(0)
	var file = FileAccess.open("res://addons/object_creator/Assets/resource_classes.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	resourceClasses = JSON.parse_string(json_string)

func create_class_buttons(classObjects: Array, return_callable: Callable):
	var totalPosition = margin
	for object: ClassObject in classObjects:
		if check_class_requirements(object):
			var newButton = buttonScene.instantiate()
			newButton.classObject = object
			newButton.connect("class_chosen", return_callable)
			flowContainer.add_child(newButton)

func check_class_requirements(object: ClassObject) -> bool:
	var classScript: String = load(object.path).source_code
	var isResourceClass = false
	for string in resourceClasses:
		if classScript.contains("extends " + string):
			isResourceClass = true
			break
	if isResourceClass == false:
		return false
	return true
