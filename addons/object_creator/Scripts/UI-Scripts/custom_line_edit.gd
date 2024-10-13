@tool
class_name CustomLineEdit
extends LineEdit

@export var input_type: Variant.Type ## expected type of input, choosing int for example will only allow int values for retriaval
@export var input_max: int ## float or int for a max int/float range (inclusive)
@export var activated_max = false ## bool variable to active the max
@export var input_min: int ## float or int for min int/float range (inclusive)
@export var activated_min = false ## bool variable to active the min
@export var accept_numbersOnly = false ## if set to true only numbers will be accepted
@export var excluded_values: Array ## array that checks for chars or substrings and rejects them when retrieving

func _ready():
	connect("text_changed", Callable(self, "on_text_changed"))

func retrieve_input():
	if text.is_empty():
		return ""

	match input_type:
		TYPE_INT:
			if not text.is_valid_int():
				return Enums.InputErrorType.TYPE_INVALID
			else:
				var number_string = int(text)
				if activated_max and number_string > input_max:
					return Enums.InputErrorType.RANGE_INVALID
				if activated_min and number_string < input_min:
					return Enums.InputErrorType.RANGE_INVALID
				
		TYPE_FLOAT:
			if not text.is_valid_float():
				return Enums.InputErrorType.TYPE_INVALID
			else:
				var number_string = float(text)
				if activated_max and number_string > input_max:
					return Enums.InputErrorType.RANGE_INVALID
				if activated_min and number_string < input_min:
					return Enums.InputErrorType.RANGE_INVALID
	
	# this one is not currently in use really
	for item in excluded_values:
		if text.contains(str(item)):
			return Enums.InputErrorType.INVALID
	
	return text

func on_text_changed(newText: String):
	## TODO add better auto delete
	if accept_numbersOnly:
		var newInput = text.right(1)
		for char in text:
			if not char.is_valid_int() and not ("1" + char).is_valid_float():
				text = text.replace(char, "")
