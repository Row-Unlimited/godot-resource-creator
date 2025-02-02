@tool
extends Control

@onready var continue_button = $PopupWindow/ContinueButton
@onready var cancel_button = $PopupWindow/CancelButton
@onready var header_label = $PopupWindow/HeaderLabel
@onready var large_label = $PopupWindow/LargeLabelBackground/LargeCustomLabel

signal popup_continue
signal popup_cancel(popup)

var header_text = "" :
	set(value):
		header_text = value
		if is_node_ready():
			header_label.text = value
		pass
var label_text = "" :
	set(value):
		label_text = value
		if is_node_ready():
			large_label.text = value

func _ready() -> void:
	header_label.text = header_text
	large_label.text = label_text
	continue_button.connect("pressed", _on_continue_pressed)
	cancel_button.connect("pressed", _on_cancel_pressed)

func set_text_vars(header_string: String = "", label_string: String = ""):
	if header_string:
		header_text = header_string
	if label_string:
		label_text = label_string

func _on_continue_pressed():
	emit_signal("popup_continue")

func _on_cancel_pressed():
	emit_signal("popup_cancel", self)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			continue_button.emit_signal("pressed")
		if event.keycode == KEY_ESCAPE:
			cancel_button.emit_signal("pressed")
