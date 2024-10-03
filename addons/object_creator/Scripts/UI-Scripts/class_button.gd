@tool
extends Button

var object_wrapper: ObjectWrapper:
	set(value):
		object_wrapper = value
		if object_wrapper.file_class_name != null:
			text = object_wrapper.file_class_name

signal class_chosen(object_wrapper: ObjectWrapper)

func _pressed():
	emit_signal("class_chosen", object_wrapper)
