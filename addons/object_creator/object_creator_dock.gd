@tool
extends EditorPlugin
const scenePath = "res://addons/object_creator/Scenes/startup_scene.tscn"
var dock

func _enter_tree():
	dock = preload(scenePath).instantiate()
	add_child(dock)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
