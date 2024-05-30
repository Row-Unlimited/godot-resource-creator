@tool
extends InputManager
## default input box used for int/String/float

var isInt: bool


func set_up_nodes():
	typeLabel = get_node("InputContainer/PropertyType")
	nameLabel = get_node("InputContainer/PropertyName")
	inputNode = get_node("InputContainer/Input")
	inputWarning = get_node("WarningContainer/WrongInputWarning")
	typeLabel.text = return_type_string(inputType)
	inputNode.create_vector_UI(inputType)

func initialize_input(propertyDict: Dictionary):
	property = propertyDict
	typeLabel = get_node("InputContainer/PropertyType")
	nameLabel = get_node("InputContainer/PropertyName")
	inputNode = get_node("InputContainer/Input")
	inputWarning = get_node("WarningContainer/WrongInputWarning")
	
	nameLabel.text = property["name"]
	typeLabel.text = return_type_string(property["type"])
	
	inputNode.create_vector_UI(property["type"])

func attempt_submit() -> Variant:
	var returnValue = null
	var tempValue = inputNode.return_input()
	
	if check_input_range(tempValue) or tempValue == null:
		returnValue = null
		show_input_warning()
	else:
		returnValue = tempValue
	return returnValue

