@tool
extends EditorPlugin
const scenePath = "res://addons/object_creator/Scenes/main_scene.tscn"
const PLUGIN_CONFIG_PATH = "res://addons/object_creator/PluginConfig.tres"
var dock
var plugin_config = preload(PLUGIN_CONFIG_PATH)

func _enter_tree():
	dock = preload(scenePath).instantiate()
	
	EditorInterface.get_editor_main_screen().add_child(dock)
	
	_make_visible(false)

func _has_main_screen():
	return true

func _make_visible(visible):
	if dock:
		dock.visible = visible

func _get_plugin_name():
	return "Object Creator Plugin"

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
