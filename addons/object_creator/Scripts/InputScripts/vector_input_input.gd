@tool
extends GridContainer
## Gridcontainer class which handles the different Vector variations

var x_input: CustomLineEdit
var y_input: CustomLineEdit
var z_input: CustomLineEdit
var wInput: CustomLineEdit

var isInt = false
var vector_type
var variable_number: int
var input_array: Array

func _ready():
	x_input = $X
	input_array.append(x_input)
	y_input = $Y
	input_array.append(y_input)
	z_input = $Z
	wInput = $W

func create_vector_UI(type: Variant.Type):
	vector_type = type
	match vector_type:
		Variant.Type.TYPE_VECTOR2:
			variable_number = 2
		Variant.Type.TYPE_VECTOR2I:
			isInt = true
			variable_number = 2
		Variant.Type.TYPE_VECTOR3:
			variable_number = 3
			input_array.append(z_input)
		Variant.Type.TYPE_VECTOR3I:
			isInt = true
			variable_number = 3
			input_array.append(z_input)
		Variant.Type.TYPE_VECTOR4:
			variable_number = 4
			input_array.append(z_input)
			input_array.append(wInput)
		Variant.Type.TYPE_VECTOR4I:
			isInt = true
			variable_number = 4
			input_array.append(z_input)
			input_array.append(wInput)
	
	for input in input_array:
		input.visible = true


func return_input(accept_empty_inputs) -> Variant:
	var value_array = []
	var return_vector
	for input in input_array:
		var temp_value: String = input.retrieve_input()

		if temp_value.is_empty():
			if accept_empty_inputs:
				value_array.append(0 if isInt else 0.)
			else:
				return null
		elif check_valid(temp_value):
			value_array.append(temp_value.to_int() if isInt else temp_value.to_float())
		else:
			return null
	
	match vector_type:
		Variant.Type.TYPE_VECTOR2:
			return_vector = Vector2(value_array[0], value_array[1])
		Variant.Type.TYPE_VECTOR2I:
			return_vector = Vector2i(value_array[0], value_array[1])
		Variant.Type.TYPE_VECTOR3:
			return_vector = Vector3(value_array[0], value_array[1], value_array[2])
		Variant.Type.TYPE_VECTOR3I:
			return_vector = Vector3i(value_array[0], value_array[1], value_array[2])
		Variant.Type.TYPE_VECTOR4:
			return_vector = Vector4(value_array[0], value_array[1], value_array[2], value_array[3])
		Variant.Type.TYPE_VECTOR4I:
			return_vector = Vector4i(value_array[0], value_array[1], value_array[2], value_array[3])
	return return_vector

## checks if a vector input is valid
func check_valid(value):
	return (value.is_valid_int() if isInt else value.is_valid_float())
		
