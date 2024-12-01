@tool
class_name DataTypeOptionButton
extends OptionButton

func return_type_by_index(index: int) -> Variant.Type:
	var item = get_item_text(index)
	var return_type: Variant.Type
	match item:
		"String":
			return_type = TYPE_STRING
		"int":
			return_type = TYPE_INT
		"float":
			return_type = TYPE_FLOAT
		"bool":
			return_type = TYPE_BOOL
		"Array":
			return_type = TYPE_ARRAY
		"Dictionary":
			return_type = TYPE_DICTIONARY
		"Vector 2":
			return_type = TYPE_VECTOR2
		"Vector 2i":
			return_type = TYPE_VECTOR2I
		"Vector 3":
			return_type = TYPE_VECTOR3
		"Vector 3i":
			return_type = TYPE_VECTOR3I
		"Vector 4":
			return_type = TYPE_VECTOR4
		"Vector 4i":
			return_type = TYPE_VECTOR4I
		"Object":
			return_type = TYPE_OBJECT
	
	return return_type
