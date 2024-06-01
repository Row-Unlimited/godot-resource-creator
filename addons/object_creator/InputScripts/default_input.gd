@tool
extends InputManager
## default input box used for int/String/float



func set_up_nodes():
	typeLabel = get_node("InputContainer/PropertyType")
	nameLabel = get_node("InputContainer/PropertyName")
	inputNode = get_node("InputContainer/Input")
	inputWarning = get_node("WarningContainer/WrongInputWarning")
	typeLabel.text = return_type_string(inputType)


func initialize_input(propertyDict: Dictionary):
	set_up_nodes()
	set_property_information(propertyDict)
	style_input()

func attempt_submit() -> Variant:
	var returnValue = null
	var tempValue: String = inputNode.text
	match inputType:
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

func style_input():
	nameLabel.text = property["name"]
	typeLabel.text = return_type_string(property["type"])
