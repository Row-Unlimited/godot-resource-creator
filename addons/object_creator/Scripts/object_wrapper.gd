@tool
class_name ObjectWrapper
extends Resource

@export var times_used: int = 0 ## how often this class was created, is used to sort the classes in the choice window
@export var file_class_name: String
## path to the script
@export var path: String
## custom export path if one is assigned
var export_path = ""
## id that is assigned after a creation process is started
var id
var parent_wrapper: ObjectWrapper
var obj
var real_class_name: String

var class_config

func _init(path: String = "", name: String = "", obj = null, times_used = 0):
	self.path = path
	file_class_name = name
	self.times_used = times_used
	self.obj = obj
	get_class_name()

func get_class_name():
	if path:
		var source_code = load(path).new().get_script().source_code
		var regex = RegEx.new()
		regex.compile(r"class_name ([^\s]*)")
		var finding = regex.search(source_code)
		real_class_name = finding.get_string(1) if finding else ""
