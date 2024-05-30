@tool
class_name DataTypeOptionButton
extends OptionButton

func return_type_by_index(index: int) -> Variant.Type:
	var item = get_item_text(index)
	var returnType: Variant.Type
	match item:
		"String":
			returnType = TYPE_STRING
		"int":
			returnType = TYPE_INT
		"float":
			returnType = TYPE_FLOAT
		"bool":
			returnType = TYPE_BOOL
		"Array":
			returnType = TYPE_ARRAY
		"Vector 2":
			returnType = TYPE_VECTOR2
		"Vector 2i":
			returnType = TYPE_VECTOR2I
		"Vector 3":
			returnType = TYPE_VECTOR3
		"Vector 3i":
			returnType = TYPE_VECTOR3I
		"Vector 4":
			returnType = TYPE_VECTOR4
		"Vector 4i":
			returnType = TYPE_VECTOR4I
	
	return returnType
