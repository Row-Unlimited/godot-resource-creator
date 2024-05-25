@tool
extends GridContainer
## Gridcontainer class which handles the different Vector variations

var xInput: CustomLineEdit
var yInput: CustomLineEdit
var zInput: CustomLineEdit
var wInput: CustomLineEdit

var isInt = false
var vectorType
var variableNumber: int
var inputArray: Array

func _ready():
	xInput = $X
	inputArray.append(xInput)
	yInput = $Y
	inputArray.append(yInput)
	zInput = $Z
	wInput = $W

func create_vector_UI(type: Variant.Type):
	vectorType = type
	match vectorType:
		Variant.Type.TYPE_VECTOR2:
			variableNumber = 2
		Variant.Type.TYPE_VECTOR2I:
			isInt = true
			variableNumber = 2
		Variant.Type.TYPE_VECTOR3:
			variableNumber = 3
			inputArray.append(zInput)
		Variant.Type.TYPE_VECTOR3I:
			isInt = true
			variableNumber = 3
			inputArray.append(zInput)
		Variant.Type.TYPE_VECTOR4:
			variableNumber = 4
			inputArray.append(zInput)
			inputArray.append(wInput)
		Variant.Type.TYPE_VECTOR4I:
			isInt = true
			variableNumber = 4
			inputArray.append(zInput)
			inputArray.append(wInput)
	
	for input in inputArray:
		input.visible = true


func return_input() -> Variant:
	var valueArray = []
	var returnVector
	for input in inputArray:
		var tempValue: String = input.retrieve_input()
		if tempValue.is_empty():
			return null
		else:
			valueArray.append(tempValue.to_int())
	
	match vectorType:
		Variant.Type.TYPE_VECTOR2:
			returnVector = Vector2(valueArray[0], valueArray[1])
		Variant.Type.TYPE_VECTOR2I:
			returnVector = Vector2i(valueArray[0], valueArray[1])
		Variant.Type.TYPE_VECTOR3:
			returnVector = Vector3(valueArray[0], valueArray[1], valueArray[2])
		Variant.Type.TYPE_VECTOR3I:
			returnVector = Vector3i(valueArray[0], valueArray[1], valueArray[2])
		Variant.Type.TYPE_VECTOR4:
			returnVector = Vector4(valueArray[0], valueArray[1], valueArray[2], valueArray[3])
		Variant.Type.TYPE_VECTOR4I:
			returnVector = Vector4i(valueArray[0], valueArray[1], valueArray[2], valueArray[3])
	return returnVector
