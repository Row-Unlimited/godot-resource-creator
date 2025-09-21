@tool
class_name Exporter
extends Node

const PLUGIN_CONFIG_PATH = "res://addons/object_creator/PluginConfig.tres"
const digit_number = 4

func export_wrappers(wrappers: Array[ObjectWrapper]):
	var path_group_dict = {}
	# sorts wrappers into groups depending on the path
	for wrapper in wrappers:
		var path = wrapper.export_path

		if path in path_group_dict.keys():
			path_group_dict[path] = path_group_dict[path] + [wrapper]
		else:
			path_group_dict[path] = [wrapper]
	
	# exports the wrappers, path by path
	for key in path_group_dict.keys():
		var path_group = path_group_dict[key]

		var normal_group = path_group.filter(func(x): return not x.export_as_json)
		var json_group = path_group.filter(func(x): return x.export_as_json)

		normal_group = normal_group.map(func(wrapper): return wrapper.obj) # turns wrapper into the objects
		json_group = json_group.map(func(wrapper): return wrapper.obj)
		export_files(key, normal_group)
		export_to_json(key, json_group)

## creates new Exporter object which will then immediately export the object(s) to the chosen path
func export_files(path: String, export_objects : Array):
	var file_names = []
	for object in export_objects:
		file_names.append(create_file_name(path, object, file_names))
	
	for i in file_names.size():
		var file = ResourceSaver.save(export_objects[i], path + file_names[i])

func export_to_json(path: String, export_objects: Array):
	var file_names = []
	for object in export_objects:
		file_names.append(create_file_name(path, object, file_names, true))
	
	# make it into a dict so we can stringify it

	for i in file_names.size():
		var object_string = Helper.object_to_dict(export_objects[i])
		var file = FileAccess.open(path + file_names[i], FileAccess.WRITE)
		file.store_string(JSON.stringify(object_string))
		file.close()

func create_file_name(path: String, object: Object, file_names: Array, is_json=false) -> String:
	var directory = DirAccess.open(path)
	var dir_files = directory.get_files()
	dir_files.append_array(PackedStringArray(file_names))
	var number_files = 0
	var fileName: String
	var file_ending = ".tres" if not is_json else ".json"
	
	var file_header = object.get_script().get_global_name()
	file_header = file_header if file_header else Helper.get_object_script_name(object)

	for file_path in dir_files:
		if file_path.ends_with(file_ending) and file_header in file_path:
			number_files += 1

	var number_string = str(number_files)
	number_string = number_string.lpad(digit_number - number_string.length(),"0")
	fileName = file_header + "000" + str(number_files) + file_ending
	return fileName

func save_settings_file(config_object: ObjectWrapper, old_config: PluginConfig):
	var plugin_config_new = null
	if config_object.obj is PluginConfig:
		plugin_config_new = config_object.obj
		var new_plugin_values = config_object.creation_properties
		new_plugin_values = Helper.filter_dict(new_plugin_values, func(x): return "value" in x.keys())
		if new_plugin_values:
			for key in new_plugin_values.keys():
				new_plugin_values[key] = new_plugin_values[key]["value"]
			old_config = Helper.apply_dict_values_object(old_config, new_plugin_values)
			
			ResourceSaver.save(old_config, PLUGIN_CONFIG_PATH)
	else:
		Helper.throw_error("non PluginConfig object as argument in save_settings_file")
	return plugin_config_new
	
	
