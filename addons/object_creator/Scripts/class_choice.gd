@tool
extends CreationWindow
## UI Window that handles choosing which class to create an Object from

var scroll_container: ScrollContainer
var flow_container: GridContainer
const margin = 20
var button_scene = preload("res://addons/object_creator/Scenes/class_button.tscn")
var resource_classes: Array


func _ready():
	scroll_container = get_child(0)
	flow_container = scroll_container.get_child(0)
	var file = FileAccess.open("res://addons/object_creator/Assets/resource_classes.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	resource_classes = JSON.parse_string(json_string)
	window_type = WindowType.CLASS_CHOICE

func create_class_buttons(object_wrappers: Array, return_callable: Callable):
	var total_position = margin
	for object: ObjectWrapper in object_wrappers:
		if check_class_requirements(object):
			var new_button = button_scene.instantiate()
			new_button.object_wrapper = object
			new_button.connect("class_chosen", return_callable)
			flow_container.add_child(new_button)

func check_class_requirements(object: ObjectWrapper) -> bool:
	var class_script: String = load(object.path).source_code
	var is_resource_class = false
	for string in resource_classes:
		if class_script.contains("extends " + string):
			is_resource_class = true
			break
	if is_resource_class == false:
		return false
	return true
