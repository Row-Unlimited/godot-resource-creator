@tool
extends CheckButton

var textTrue = "True"
var textFalse= "False"

func _ready():
	text = textFalse

func _toggled(toggled_on):
	if toggled_on:
		text = textTrue
	else:
		text = textFalse
