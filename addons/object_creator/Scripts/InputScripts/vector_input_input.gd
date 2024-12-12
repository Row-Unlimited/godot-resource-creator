@tool
extends GridContainer
## Gridcontainer class which handles the different Vector variations

var x_input: CustomLineEdit
var y_input: CustomLineEdit
var z_input: CustomLineEdit
var w_input: CustomLineEdit

var is_int = false
var vector_type
var variable_number: int
var input_array: Array

var accept_empty
var change_empty_default

	

func create_vector_UI(type: Variant.Type):
	x_input = $X
	input_array.append(x_input)
	y_input = $Y
	input_array.append(y_input)
	z_input = $Z
	w_input = $W
	vector_type = type
	match vector_type:
		Variant.Type.TYPE_VECTOR2:
			variable_number = 2
		Variant.Type.TYPE_VECTOR2I:
			is_int = true
			variable_number = 2
		Variant.Type.TYPE_VECTOR3:
			variable_number = 3
			input_array.append(z_input)
		Variant.Type.TYPE_VECTOR3I:
			is_int = true
			variable_number = 3
			input_array.append(z_input)
		Variant.Type.TYPE_VECTOR4:
			variable_number = 4
			input_array.append(z_input)
			input_array.append(w_input)
		Variant.Type.TYPE_VECTOR4I:
			is_int = true
			variable_number = 4
			input_array.append(z_input)
			input_array.append(w_input)
	
	for input in input_array:
		input.visible = true
		input.input_type = TYPE_INT if is_int else TYPE_FLOAT


func return_input() -> Variant:
	var value_array = []
	var return_vector
	for input in input_array:
		var temp_value = input.retrieve_input()
		var error_object: InputError
		error_object = temp_value if temp_value is InputError else InputError.new_error_object()


		if error_object.has_any_errors(["EMPTY"]):
			return error_object
		elif error_object.has_any_errors(["EMPTY"]):
			if accept_empty:
				if change_empty_default:
					value_array.append([0, 0, 0, 0].resize(variable_number))
				else:
					value_array.append(InputError.new_error_object(["IGNORE"]))
			else:
				value_array.append(error_object)
		else:
			value_array.append(temp_value)
	
	# TODO: fix error behavior for vectors
	return_vector = Helper.custom_to_vector(value_array, is_int)
	return return_vector

## checks if a vector input is valid
func check_valid(value):
	return (value.is_valid_int() if is_int else value.is_valid_float())
		
