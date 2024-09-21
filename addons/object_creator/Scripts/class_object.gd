@tool
class_name ClassObject
extends Resource

@export var times_used: int = 0 ## how often this class was created, is used to sort the classes in the choice window
@export var name_class: String
@export var path: String
var premade_object

func _init(path: String, name: String, pre_object = null, times_used = 0):
	self.path = path
	name_class = name
	self.times_used = times_used
	self.premade_object = pre_object
