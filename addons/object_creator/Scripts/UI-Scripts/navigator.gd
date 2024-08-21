@tool
extends Control

var active_window: Window
var UIControl: Control
var scale_percentX: float = 1
var scale_percentY: float = 1

var button_box: VBoxContainer
var confirmation_box: VBoxContainer
var current_box: VBoxContainer
var navigator_label: Label

var back_button: Button
var reset_button: Button
var confirm_button: Button
var cancel_button: Button

var is_reset: bool

const MIN_SCALE = 0.5
const MIN_DEFAULT_WINDOW_SIZE = Vector2(350, 500)
const MIN_SCALE_SIZE = Vector2(100, 150)

signal navigator_pressed(is_reset)

func _ready():
	button_box = get_node("UIControl/ButtonBox")
	confirmation_box = get_node("UIControl/ConfirmationBox")
	back_button = get_node("UIControl/ButtonBox/BackButton")
	back_button.connect("pressed", Callable(self, "on_back_pressed"))
	reset_button = get_node("UIControl/ButtonBox/ResetButton")
	reset_button.connect("pressed", Callable(self, "on_reset_pressed"))
	confirm_button = get_node("UIControl/ConfirmationBox/ConfirmButton")
	confirm_button.connect("pressed", Callable(self, "on_confirm_pressed"))
	cancel_button = get_node("UIControl/ConfirmationBox/CancelButton")
	cancel_button.connect("pressed", Callable(self, "toggle_box"))
	current_box = button_box
	navigator_label = get_node("UIControl/Label")
	
	active_window = get_tree().root
	UIControl = get_node("UIControl")
	active_window.connect("size_changed", Callable(self, "handle_resize"))
	
	style_navigator()

func on_back_pressed():
	is_reset = false
	toggle_box()
	navigator_label.text = "Back?"

func on_reset_pressed():
	is_reset = true
	toggle_box()
	navigator_label.text = "Reset?"

func on_confirm_pressed():
	emit_signal("navigator_pressed", is_reset)
	toggle_box()

func toggle_box():
	var old_box = current_box
	if current_box == button_box:
		current_box = confirmation_box
	else:
		current_box = button_box
		navigator_label.text = "Navigator"
	old_box.visible = false
	current_box.visible = true

func handle_resize():
	var allowed_scale_size: Vector2 = MIN_DEFAULT_WINDOW_SIZE - MIN_SCALE_SIZE
	var percentage_step: Vector2 = allowed_scale_size / (100 * MIN_SCALE)
	
	if active_window.size.x < MIN_DEFAULT_WINDOW_SIZE.x:
		if active_window.size.x < MIN_SCALE_SIZE.x:
			scale_percentX = MIN_SCALE
		else:
			scale_percentX = ((active_window.size.x - MIN_SCALE_SIZE.x) / percentage_step.x) * 0.01
			scale_percentX += MIN_SCALE
	else:
		scale_percentX = 1
	if active_window.size.y < MIN_DEFAULT_WINDOW_SIZE.y:
		if active_window.size.y < MIN_SCALE_SIZE.y:
			scale_percentY = MIN_SCALE
		else:
			scale_percentY = ((active_window.size.y - MIN_SCALE_SIZE.y) / percentage_step.y) * 0.01 
			scale_percentY += MIN_SCALE
	else:
		scale_percentY = 1
	UIControl.scale = Vector2(scale_percentX, scale_percentY)

func style_navigator():
	var color_rect = get_node("ColorRect")
	var root = EditorInterface.get_base_control()
	var accent_color = root.get_theme_color("accent_color", "Editor")
	var base_color = root.get_theme_color("base_color", "Editor")
	color_rect.color = base_color * 0.5
	var hello = tr
	var accent_average = ((accent_color.r + accent_color.b + accent_color.g)/3)
	var base_average = ((base_color.r + base_color.b + base_color.g)/3)
	var base_modifier = 0.5 if base_average > 0.5 else 1.3
	var accent_modifier = 1.3 if accent_average < 0.5 else 0.5
	
	back_button.get_theme_stylebox("hover").bg_color = accent_color * accent_modifier
	back_button.get_theme_stylebox("normal").bg_color = base_color * base_modifier
	back_button.get_theme_stylebox("pressed").bg_color = accent_color
