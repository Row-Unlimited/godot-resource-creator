@tool
class_name ClassObject
extends Object

var timesUsed: int = 0 ## how often this class was created, is used to sort the classes in the choice window
var className: String
var path: String

func _init(path: String, name: String):
	self.path = path
	className = name
