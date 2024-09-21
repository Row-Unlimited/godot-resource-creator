@tool
class_name CreationManager
extends Node

const PLUGIN_CONFIG_PATH = "res://addons/object_creator/PluginConfig.tres"
const SETTINGS_CLASS_PATH = "res://addons/object_creator/Scripts/plugin_config.gd"

var create_object_screen = preload("res://addons/object_creator/Scenes/create_object.tscn")
var class_choice_screen = preload("res://addons/object_creator/Scenes/class_choice.tscn")

## holds the information for all ongoing create object processes
## example: {class_path:"", export_path:"", process_id:"12", parent_process_id:"1", session_dict:""}
var object_processes: Array[Dictionary]
var tab_manager: TabManager


func _ready() -> void:
	tab_manager = get_node("TabManager")
	tab_manager.create_new_tab("test other tab", class_choice_screen.instantiate())
	create_new_object(null)


func create_new_object(class_object: ClassObject):
	var new_create_window = create_object_screen.instantiate()
	tab_manager.create_new_tab("test_tab", new_create_window)

## deletes object process by ID
func delete_object_process(object_id: int):
	pass
