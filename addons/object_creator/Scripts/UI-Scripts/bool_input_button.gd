@tool
extends CheckButton

var text_true = "True"
var text_false= "False"

func _ready():
	text = text_false

func _toggled(toggled_on):
	if toggled_on:
		text = text_true
	else:
		text = text_false
