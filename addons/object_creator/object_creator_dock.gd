@tool
extends EditorPlugin
const scenePath = "res://addons/object_creator/Scenes/startup_scene.tscn"
var dock

func _enter_tree():
	dock = preload(scenePath).instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	dock.start_creation_process()


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
