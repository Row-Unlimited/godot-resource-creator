@tool
class_name ObjectWrapper
extends Resource

@export var times_used: int = 0 ## how often this class was created, is used to sort the classes in the choice window
@export var file_class_name: String
## path to the script
@export var path: String
## custom export path if one is assigned
var export_path = ""
## id that is assigned after a creation process is started
var id
var parent_wrapper: ObjectWrapper
var obj
var real_class_name: String

var number_constructor_args: int = 0
var constructor_args: Array
var constr_invalid: bool = false

var obj_script: Script
var class_config = {}

func _init(path: String = "", name: String = "", obj = null, times_used = 0, config = {}):
	self.path = path
	file_class_name = name
	self.times_used = times_used
	self.obj = obj
	self.class_config = config
	set_script_info()
	if class_config and "constructor_values" in class_config.keys():
		constructor_args = class_config["constructor_values"]
		if constructor_args.size() < number_constructor_args:
			constr_invalid = true

func set_script_info():
	if path:
		obj_script = load(path)
		real_class_name = obj_script.get_global_name()
		var constr_args = Helper.return_func_arg_optionality(load(path), "_init")
		number_constructor_args = constr_args.filter(func(x): return not x["is_optional"]).size()
		
## uses a [param properties] dict to create an object and assign values from the dict [br]
## properties is supposed to be the basic property_list dictionary you can get from the gdscript object class, but with another key "value" added [br]
## If the object class needs arguments for the constructor, it takes those from the config "constructor_values" variable.
func create_object(properties: Dictionary):
	var value_dict: Dictionary = {}
	for prop_name in properties.keys():
		if "value" in properties[prop_name].keys():
			value_dict[prop_name] = properties[prop_name]["value"]

	# replace VAR_NAME in constructor args
	for i in constructor_args.size():
		var arg = constructor_args[i]
		if typeof(arg) == TYPE_STRING and "VAR_NAME" in arg:
			var var_name = Array(arg.split(":")).back()
			if var_name in value_dict.keys():
				constructor_args[i] = value_dict[var_name]
	
	for key in value_dict.keys():
		var value = value_dict[key]
		if typeof(value) == TYPE_STRING and "VAR_NAME" in value:
			var var_name = value.split(":").back()
			if var_name in value_dict.keys():
				value_dict[key] = value_dict[var_name]
			else:
				value_dict[key] = null

	obj = obj_script.callv("new", constructor_args)
	Helper.apply_dict_values_object(obj, value_dict)
