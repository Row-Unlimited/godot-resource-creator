@tool
class_name ObjectWrapper
extends Resource

@export var times_used: int = 0 ## how often this class was created, is used to sort the classes in the choice window
@export var name_class: String
## path to the script
@export var path: String
## custom export path if one is assigned
var export_path = ""
## id that is assigned after a creation process is started
var id
var parent_wrapper: ObjectWrapper
var obj

func _init(path: String = "", name: String = "", obj = null, times_used = 0):
	self.path = path
	name_class = name
	self.times_used = times_used
	self.obj = obj

