@tool
extends InputManager

func initialize_input(propertyDict: Dictionary):
	property = propertyDict
	typeLabel = get_node("InputContainer/PropertyType")
	nameLabel = get_node("InputContainer/PropertyName")
	inputNode = get_node("InputContainer/Input")
	inputWarning = get_node("WarningContainer/WrongInputWarning")
	
	style_input()

func attempt_submit() -> Variant:
	var returnValue = null
	var tempValue: String = inputNode.text
	match property["type"]:
		Variant.Type.TYPE_INT:
			if tempValue.is_valid_int():
				returnValue = tempValue.to_int()
		Variant.Type.TYPE_FLOAT:
			if tempValue.is_valid_float():
				returnValue = tempValue.to_float()
		Variant.Type.TYPE_STRING:
			if not tempValue.is_empty():
				returnValue = tempValue
		Variant.Type.TYPE_NODE_PATH:
			pass
	
	if not check_input_range(returnValue) or returnValue == null:
		returnValue = null
		show_input_warning()
	return returnValue

func show_input_warning():
	pass

func style_input():
	nameLabel.text = property["name"]
	typeLabel.text = return_type_string(property["type"])
	
