@tool
class_name DataTypeOptionButton
extends OptionButton

func return_type_by_index(index: int) -> Variant.Type:
	var item = get_item_text(index)
	var return_type: Variant.Type
	
	return TypeManager.find_type_value(item, TypeManager.TypeValue.TYPE_ENUM)
