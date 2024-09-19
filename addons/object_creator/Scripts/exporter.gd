@tool
class_name Exporter
extends Node

const PLUGIN_CONFIG_PATH = "res://addons/object_creator/PluginConfig.tres"

## creates new Exporter object which will then immediately export the object(s) to the chosen path
func export_files(path: String, export_objects : Array):
	var file_names = []
	for object in export_objects:
		file_names.append(create_file_name(path, object))
	
	for i in file_names.size():
		var file = ResourceSaver.save(export_objects[i], path + file_names[i])


func export_to_json(path: String, export_objects: Array):
	var file_names = []
	for object in export_objects:
		file_names.append(create_file_name(path, object, true))
	
	# make it into a dict so we can stringify it

	for i in file_names.size():
		var object_string = Helper.object_to_dict(export_objects[i])
		var file = FileAccess.open(path + file_names[i], FileAccess.WRITE)
		file.store_string(JSON.stringify(object_string))
		file.close()

func create_file_name(path: String, object: Object, is_json=false) -> String:
	var directory = DirAccess.open(path)
	var dir_files = directory.get_files()
	var number_files = 0
	var fileName: String
	var file_ending = ".tres" if not is_json else ".json"
	
	for filePath in dir_files:
		if filePath.ends_with(file_ending):
			number_files += 1
	
	var file_header = object.get_script().get_global_name()
	file_header = file_header if file_header else Helper.get_object_script_name(object)

	fileName = file_header + "000" + str(number_files) + file_ending
	return fileName

func save_settings_file(config_object: PluginConfig):
	var skipped_properties =["resource_local_to_scene", "resource_path", "resource_name"]
	var current_config = load(PLUGIN_CONFIG_PATH)
	Helper.print_object_values(current_config, skipped_properties)
	Helper.update_object(current_config, config_object)
	Helper.print_object_values(current_config, skipped_properties)
	ResourceSaver.save(current_config, PLUGIN_CONFIG_PATH)
	
