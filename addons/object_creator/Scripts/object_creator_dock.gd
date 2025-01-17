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
	
	dock.connect("reload_plugin", _on_reload_plugin)

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
	return load("res://addons/object_creator/Assets/textures/icon_file_new.png")

func _on_reload_plugin():
	var main_scene = EditorInterface.get_editor_main_screen().get_children().filter(func(x): return x is CreationManager)
	if main_scene:
		main_scene = main_scene[0]
	EditorInterface.get_editor_main_screen().remove_child(main_scene)
	dock.queue_free()
	_enter_tree()
	_make_visible(true)
	
