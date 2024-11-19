@tool
class_name ClassLoader
extends Node
## searches through project structure (excluding .git/.godot) and fetches all custom classes that can be created

const plugin_configPath = "res://addons/object_creator/PluginConfig.tres"
var plugin_config = preload(plugin_configPath)

func check_for_integration() -> bool:
	if plugin_config.isIntegrated:
		return true
	else:
		return false

func return_integrated_classes() -> Array:
	var ClassArray = []
	for path in plugin_config.integrated_classPaths:
		ClassArray.append(ObjectWrapper.new(path, Helper.get_last_path_parts(path, 1)[0]))
	
	return ClassArray

## returns ObjectWrapper objects for each creatable class in the project [br]
## certain directories are/can-be excluded through the plugin_config
func return_possible_classes() -> Array:
	var wrapper_array = []
	var start_path = "res://"
	var filePaths: Array = Helper.search_filetypes_in_directory(".gd", start_path, plugin_config.ignored_directories)
	filePaths.append_array(Helper.search_filetypes_in_directory(".cs", start_path, plugin_config.ignored_directories))
	var temp_wrappers = []
	
	for path in filePaths:
		var name = Helper.get_last_path_parts(path, 1)[0]
		var wrapper_config = plugin_config.get_config_by_path(path)
		var new_wrapper = ObjectWrapper.new(path, name, null, 0, wrapper_config)
		if new_wrapper.constr_invalid:
			Helper.throw_error("No constructor values given in config for class " + new_wrapper.real_class_name + " with constructor")
			continue

		temp_wrappers.append(new_wrapper)
	
	# maybe add functionality that checks each class for a certain prerequisite
	wrapper_array = temp_wrappers
	
	return wrapper_array

## will replace integrated classes and use the creation_config in plugin_config
func return_sub_classes() -> Array:
	


	return []
