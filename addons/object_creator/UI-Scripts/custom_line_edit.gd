@tool
class_name CustomLineEdit
extends LineEdit

@export var inputType: Variant.Type ## expected type of input, choosing int for example will only allow int values for retriaval
@export var inputMax: int ## float or int for a max int/float range (inclusive)
@export var activatedMax = false ## bool variable to active the max
@export var inputMin: int ## float or int for min int/float range (inclusive)
@export var activatedMin = false ## bool variable to active the min
@export var acceptNumbersOnly = false ## if set to true only numbers will be accepted
@export var excludedValues: Array ## array that checks for chars or substrings and rejects them when retrieving

func _ready():
	connect("text_changed", Callable(self, "on_text_changed"))

func retrieve_input() -> String:
	match inputType:
		TYPE_INT:
			if not text.is_valid_int():
				return ""
			else:
				var numberString = int(text)
				if activatedMax and numberString > inputMax:
					return ""
				if activatedMin and numberString < inputMin:
					return ""
				
		TYPE_FLOAT:
			if not text.is_valid_float():
				return ""
			else:
				var numberString = float(text)
				if activatedMax and numberString > inputMax:
					return ""
				if activatedMin and numberString < inputMin:
					return ""
	
	for item in excludedValues:
		if text.contains(str(item)):
			return ""
	
	return text

func on_text_changed(newText: String):
	if acceptNumbersOnly:
		var newInput = text.right(1)
		for char in text:
			if not char.is_valid_int():
				text = text.replace(char, "")
