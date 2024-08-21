@tool
class_name PathTuple
extends Object

var path: String
var times_used: int

func _init(path_string: String):
	path = path_string
	times_used = 1
