@tool
class_name Helper
extends Object

static func check_string_contains_array(stringArray: Array, checkString: String):
	for string: String in stringArray:
		if checkString.contains(string):
			return true
	return false
