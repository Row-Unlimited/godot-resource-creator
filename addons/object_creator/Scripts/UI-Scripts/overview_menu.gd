@tool
class_name OverviewMenu
extends Control

signal export_activated(path_dict: Dictionary)
signal export_errors_detected(error_ids: Array)

@onready var export_button: Button = $ExportMenu/ExportButton
@onready var export_tree: TreeExportView = $ExportMenu/ExportTree

func _ready() -> void:
	export_button.connect("pressed", Callable(self, "_on_export_button_pressed"))


## checks if paths are non-existant or invalid and changes the tree UI so the user sees the error
## otherwise it sends a signal with the path dict so the creation_manager can start exporting
func _on_export_button_pressed():
	var path_dict = export_tree.submit_wrapper_paths()
	var error_ids = []
	for key in path_dict:
		var path = path_dict[key]
		if not path or not DirAccess.dir_exists_absolute(path):
			# TODO: once sub objects are implemented this will create an issue since sub_objects have no path but should be shown by the tree for editing
			error_ids.append(key)
	
	if error_ids.is_empty():
		emit_signal("export_activated", path_dict)
	else:
		var error_color = Color(1, 0, 0)
		export_tree.set_color_items(error_ids, error_color, true)
