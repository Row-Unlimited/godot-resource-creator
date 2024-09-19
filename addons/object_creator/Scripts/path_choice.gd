@tool
extends CreationWindow
## UI Window which makes it possible for the User to select an export path

var input_new: LineEdit
var input_known: OptionButton
var export_button: Button
var warning_label: Label
var plugin_config: PluginConfig
var json_button: CheckButton

var should_save_json: bool

signal path_chosen(path: String, is_json: bool)

func _ready() -> void:
	window_type = WindowType.PATH_CHOICE
	json_button = $ScrollContainer/VBoxContainer/JSONButton
	json_button.connect("toggled", Callable(self, "_on_json_button_toggled"))

func initialize_UI(config: PluginConfig):
	input_new = get_node("ScrollContainer/VBoxContainer/AddPathInput")
	input_known = get_node("ScrollContainer/VBoxContainer/KnownPathSelection")
	export_button = get_node("ExportArea/Button")
	warning_label = get_node("ExportArea/WarningLabel")
	export_button.connect("pressed", Callable(self, "on_export_pressed"))
	plugin_config = config
	
	
	# TODO: sort OptionButton according to pathTuple.times_used var
	for pathTuple: PathTuple in plugin_config.used_exportPaths:
		if DirAccess.dir_exists_absolute(pathTuple.path):
			input_known.add_item(pathTuple.path)

func on_export_pressed():
	var path_string: String
	if input_known.selected != -1:
		path_string = input_known.get_item_text(input_known.selected)
	else:
		if input_new.text.is_empty():
			warning_label.text = "You have not chosen a path please try again"
			warning_label.visible = true
			return
		else:
			path_string = input_new.text

	if DirAccess.dir_exists_absolute(path_string):
		emit_signal("path_chosen", path_string, should_save_json)
	else:
		warning_label.text = "You're chosen directory does not seem to exist, please try again"
		warning_label.visible = true

func _on_json_button_toggled(is_json: bool):
	should_save_json = is_json