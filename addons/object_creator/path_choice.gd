@tool
extends Control
## UI Window which makes it possible for the User to select an export path

var inputNew: LineEdit
var inputKnown: OptionButton
var exportButton: Button
var warningLabel: Label
var pluginConfig: PluginConfig

signal path_chosen(path: String)

func initialize_UI(config: PluginConfig):
	inputNew = get_node("ScrollContainer/VBoxContainer/AddPathInput")
	inputKnown = get_node("ScrollContainer/VBoxContainer/KnownPathSelection")
	exportButton = get_node("ExportArea/Button")
	warningLabel = get_node("ExportArea/Label")
	exportButton.connect("pressed", Callable(self, "on_export_pressed"))
	pluginConfig = config
	
	
	# TODO: sort OptionButton according to pathTuple.timesUsed var
	for pathTuple: PathTuple in pluginConfig.usedExportPaths:
		if DirAccess.dir_exists_absolute(pathTuple.path):
			inputKnown.add_item(pathTuple.path)

func on_export_pressed():
	var pathString: String
	if inputKnown.selected != -1:
		pathString = inputKnown.get_item_text(inputKnown.selected)
	else:
		if inputNew.text.is_empty():
			warningLabel.text = "You have not chosen a path please try again"
			warningLabel.visible = true
			return
		else:
			pathString = inputNew.text
	
	if DirAccess.dir_exists_absolute(pathString):
		emit_signal("path_chosen", pathString)
	else:
		warningLabel.text = "You're chosen directory does not seem to exist, please try again"
		warningLabel.visible = true
