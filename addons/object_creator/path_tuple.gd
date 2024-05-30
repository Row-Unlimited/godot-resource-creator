@tool
class_name PathTuple
extends Object

var path: String
var timesUsed: int

func _init(pathString: String):
	path = pathString
	timesUsed = 1
