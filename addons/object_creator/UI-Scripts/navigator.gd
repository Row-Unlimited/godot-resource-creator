@tool
extends Control

var buttonBox: VBoxContainer
var confirmationBox: VBoxContainer
var currentBox: VBoxContainer

var backButton: Button
var resetButton: Button
var confirmButton: Button
var cancelButton: Button

var isReset: bool

signal navigator_pressed(isReset)

func _ready():
	buttonBox = get_node("ButtonBox")
	confirmationBox = get_node("ConfirmationBox")
	backButton = get_node("ButtonBox/BackButton")
	backButton.connect("pressed", Callable(self, "on_back_pressed"))
	resetButton = get_node("ButtonBox/ResetButton")
	resetButton.connect("pressed", Callable(self, "on_reset_pressed"))
	confirmButton = get_node("ConfirmationBox/ConfirmButton")
	confirmButton.connect("pressed", Callable(self, "on_confirm_pressed"))
	cancelButton = get_node("ConfirmationBox/CancelButton")
	cancelButton.connect("pressed", Callable(self, "toggle_box"))
	currentBox = buttonBox

func on_back_pressed():
	isReset = false
	toggle_box()

func on_reset_pressed():
	isReset = true
	toggle_box()

func on_confirm_pressed():
	emit_signal("navigator_pressed", isReset)

func toggle_box():
	var oldBox = currentBox
	if currentBox == buttonBox:
		currentBox = confirmationBox
	else:
		currentBox = buttonBox
	oldBox.visible = false
	currentBox.visible = true
