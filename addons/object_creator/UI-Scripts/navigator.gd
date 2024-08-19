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
	
	style_navigator()

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
	toggle_box()

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

func style_navigator():
	var colorRect = get_node("ColorRect")
	var root = EditorInterface.get_base_control()
	var accent_color = root.get_theme_color("accent_color", "Editor")
	var base_color = root.get_theme_color("base_color", "Editor")
	colorRect.color = base_color * 0.5
	var hello = tr
	var accent_average = ((accent_color.r + accent_color.b + accent_color.g)/3)
	var base_average = ((base_color.r + base_color.b + base_color.g)/3)
	var base_modifier = 0.5 if base_average > 0.5 else 1.3
	var accent_modifier = 1.3 if accent_average < 0.5 else 0.5
	
	backButton.get_theme_stylebox("hover").bg_color = accent_color * accent_modifier
	backButton.get_theme_stylebox("normal").bg_color = base_color * base_modifier
	backButton.get_theme_stylebox("pressed").bg_color = accent_color
