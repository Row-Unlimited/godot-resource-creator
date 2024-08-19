@tool
extends TextureButton

var activeWindow: Window

var scalePercentX: float = 1
var scalePercentY: float = 1

const MIN_SCALE = 0.5
const MIN_DEFAULT_WINDOW_SIZE = Vector2(100, 100)
const MIN_SCALE_SIZE = Vector2(50, 50)

func activate_button(callable: Callable):
	activeWindow = get_tree().root
	if not activeWindow.is_connected("size_changed", Callable(self, "handle_resize")):
		activeWindow.connect("size_changed", Callable(self, "handle_resize"))
	if not self.is_connected("pressed", callable):
		self.connect("pressed", callable)

func handle_resize():
	# TODO add proper resizing
	pass
