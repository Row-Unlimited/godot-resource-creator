@tool
extends Control
## UI Window that handles choosing which class to create an Object from

var scrollContainer: ScrollContainer
var flowContainer: GridContainer
const margin = 20
var buttonScene = preload("res://addons/object_creator/Scenes/class_button.tscn")


func _ready():
	scrollContainer = get_child(0)
	flowContainer = scrollContainer.get_child(0)

func create_class_buttons(classObjects: Array):
	var totalPosition = margin
	for object: ClassObject in classObjects:
		var newButton = buttonScene.instantiate()
		newButton.classObject = object
		newButton.connect("class_chosen", Callable(get_parent(), "on_class_chosen"))
		flowContainer.add_child(newButton)
