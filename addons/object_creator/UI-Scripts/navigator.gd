@tool
extends Control

var activeWindow: Window
var UIControl: Control
var scalePercentX: float = 1
var scalePercentY: float = 1

var buttonBox: VBoxContainer
var confirmationBox: VBoxContainer
var currentBox: VBoxContainer
var navigatorLabel: Label

var backButton: Button
var resetButton: Button
var confirmButton: Button
var cancelButton: Button

var isReset: bool

const MIN_SCALE = 0.5
const MIN_DEFAULT_WINDOW_SIZE = Vector2(350, 500)
const MIN_SCALE_SIZE = Vector2(100, 150)

signal navigator_pressed(isReset)

func _ready():
	buttonBox = get_node("UIControl/ButtonBox")
	confirmationBox = get_node("UIControl/ConfirmationBox")
	backButton = get_node("UIControl/ButtonBox/BackButton")
	backButton.connect("pressed", Callable(self, "on_back_pressed"))
	resetButton = get_node("UIControl/ButtonBox/ResetButton")
	resetButton.connect("pressed", Callable(self, "on_reset_pressed"))
	confirmButton = get_node("UIControl/ConfirmationBox/ConfirmButton")
	confirmButton.connect("pressed", Callable(self, "on_confirm_pressed"))
	cancelButton = get_node("UIControl/ConfirmationBox/CancelButton")
	cancelButton.connect("pressed", Callable(self, "toggle_box"))
	currentBox = buttonBox
	navigatorLabel = get_node("UIControl/Label")
	
	activeWindow = get_tree().root
	UIControl = get_node("UIControl")
	activeWindow.connect("size_changed", Callable(self, "handle_resize"))

func on_back_pressed():
	isReset = false
	toggle_box()
	navigatorLabel.text = "Back?"

func on_reset_pressed():
	isReset = true
	toggle_box()
	navigatorLabel.text = "Reset?"

func on_confirm_pressed():
	emit_signal("navigator_pressed", isReset)

func toggle_box():
	var oldBox = currentBox
	if currentBox == buttonBox:
		currentBox = confirmationBox
	else:
		currentBox = buttonBox
		navigatorLabel.text = "Navigator"
	oldBox.visible = false
	currentBox.visible = true

func handle_resize():
	var allowed_scale_size: Vector2 = MIN_DEFAULT_WINDOW_SIZE - MIN_SCALE_SIZE
	var percentageStep: Vector2 = allowed_scale_size / (100 * MIN_SCALE)
	
	if activeWindow.size.x < MIN_DEFAULT_WINDOW_SIZE.x:
		if activeWindow.size.x < MIN_SCALE_SIZE.x:
			scalePercentX = MIN_SCALE
		else:
			scalePercentX = ((activeWindow.size.x - MIN_SCALE_SIZE.x) / percentageStep.x) * 0.01
			scalePercentX += MIN_SCALE
	else:
		scalePercentX = 1
	if activeWindow.size.y < MIN_DEFAULT_WINDOW_SIZE.y:
		if activeWindow.size.y < MIN_SCALE_SIZE.y:
			scalePercentY = MIN_SCALE
		else:
			scalePercentY = ((activeWindow.size.y - MIN_SCALE_SIZE.y) / percentageStep.y) * 0.01 
			scalePercentY += MIN_SCALE
	else:
		scalePercentY = 1
	UIControl.scale = Vector2(scalePercentX, scalePercentY)
