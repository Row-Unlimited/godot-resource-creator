@tool
extends InputManager

var toggleStatus = false

func set_up_nodes():
	typeLabel = get_node("InputContainer/PropertyType")
	nameLabel = get_node("InputContainer/PropertyName")
	inputNode = get_node("InputContainer/Input")
	inputWarning = get_node("WarningContainer/WrongInputWarning")


func initialize_input(propertyDict: Dictionary):
	property = propertyDict
	typeLabel = get_node("InputContainer/PropertyType")
	nameLabel = get_node("InputContainer/PropertyName")
	inputNode = get_node("InputContainer/Input")
	inputWarning = get_node("WarningContainer/WrongInputWarning")
	inputNode.connect("toggled", Callable(self, "on_toggled"))
	
	nameLabel.text = property["name"]
	typeLabel.text = return_type_string(property["type"])

func attempt_submit() -> Variant:
	
	return toggleStatus

func on_toggled(toggled_on):
	toggleStatus = toggled_on
