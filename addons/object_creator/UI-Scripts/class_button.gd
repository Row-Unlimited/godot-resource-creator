@tool
extends Button

var class_object: ClassObject:
	set(value):
		class_object = value
		if class_object.name_class != null:
			text = class_object.name_class

signal class_chosen(cObject: ClassObject)

func _pressed():
	emit_signal("class_chosen", class_object)
