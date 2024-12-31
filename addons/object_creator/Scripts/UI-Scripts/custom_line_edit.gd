@tool
class_name CustomLineEdit
extends LineEdit

var input_type: Variant.Type = TYPE_FLOAT ## expected type of input, choosing int for example will only allow int values for retrieval

#region config_variables
## range describes number range for int/float and size range for string/array/dictionary
var config:
	set(value):
		config = value
		apply_config()
var range_max = null
var range_min = null
var disable_editing: bool = false
var default_value = null
# TODO: maybe implement final value
#endregion

func apply_config():
	if range_max != null or range_min != null:
		var new_tooltip_text = "Range: "
		if range_min != null:
			new_tooltip_text += "(" + str(range_min) + ") - "
		if range_max != null:
			new_tooltip_text += "(" + str(range_max) + ")"
		tooltip_text = new_tooltip_text
	
	if disable_editing:
		editable = false
	
	if default_value != null:
		text = str(default_value)

func retrieve_input():
	var range_error = InputError.new_error_object(["RANGE_INVALID"])
	if text.is_empty():
		return ""

	match input_type:
		TYPE_INT:
			if not text.is_valid_int():
				return InputError.new_error_object(["TYPE_INVALID"])
			else:
				var number_string = int(text)
				if range_max != null and number_string > range_max:
					return range_error
				if range_min != null and number_string < range_min:
					return range_error
				
		TYPE_FLOAT:
			if not text.is_valid_float():
				return InputError.new_error_object(["TYPE_INVALID"])
			else:
				var number_string = float(text)
				if range_max != null and number_string > range_max:
					return range_error
				if range_min != null and number_string < range_min:
					return range_error
		_:
			Helper.throw_error("Vector Line Edit has unsupported type " + str(input_type) + " loaded!")
	
	return text
