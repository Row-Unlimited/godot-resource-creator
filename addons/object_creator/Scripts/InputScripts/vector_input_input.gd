@tool
extends GridContainer
## Gridcontainer class which handles the different Vector variations

var x_input: CustomLineEdit
var y_input: CustomLineEdit
var z_input: CustomLineEdit
var wInput: CustomLineEdit

var is_int = false
var vector_type
var variable_number: int
var input_array: Array

	

func create_vector_UI(type: Variant.Type):
	x_input = $X
	input_array.append(x_input)
	y_input = $Y
	input_array.append(y_input)
	z_input = $Z
	wInput = $W
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
			input_array.append(wInput)
		Variant.Type.TYPE_VECTOR4I:
			is_int = true
			variable_number = 4
			input_array.append(z_input)
			input_array.append(wInput)
	
	for input in input_array:
		input.visible = true


func return_input() -> Variant:
	var value_array = []
	var return_vector
	for input in input_array:
		var temp_value = input.retrieve_input()

		if temp_value in Enums.InputErrorType:
			return temp_value
		else:
			value_array.append(temp_value)
	
	return_vector = Helper.custom_to_vector(value_array, is_int)
	return return_vector

## checks if a vector input is valid
func check_valid(value):
	return (value.is_valid_int() if is_int else value.is_valid_float())
		
