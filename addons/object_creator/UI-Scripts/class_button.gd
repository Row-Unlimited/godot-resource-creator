@tool
extends Button

var classObject: ClassObject:
	set(value):
		classObject = value
		if classObject.className != null:
			text = classObject.className

signal class_chosen(cObject: ClassObject)

func _pressed():
	emit_signal("class_chosen", classObject)
	pass
