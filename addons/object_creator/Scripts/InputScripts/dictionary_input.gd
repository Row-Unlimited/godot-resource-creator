@tool
class_name DictionaryInput
extends MultiElementInput

var key_type: Variant.Type = 0
var key_object_name: String

## parses the property information and determines if property is typed.
## If so it changes UI to match that by for example disabling all other types in the type select
func check_typed():
	# this currently only returns all custom classes so other Resource sub classes would cause errors
	var possible_class_names = ClassLoader.new().return_class_names() # TODO: write function that returns all possible resource classes
	possible_class_names.append("Resource")
	var regex = RegEx.new()
	regex.compile("(?:(?<key>\\d\\d?(?:\\/\\d\\d)?):(?<key_object>\\w*))(?=\\;);(?<=\\;)(?:(?<value>\\d\\d?(?:\\/\\d\\d)?):(?<value_object>\\w*))")
	print(property)
	var type_arr
	var type_arr_key
	if "hint_string" in property.keys() and not property["hint_string"].is_empty():
		var hint_string : String = property["hint_string"]
		var search_hint = regex.search(hint_string)
		var hint_key = search_hint.get_string("key")
		var hint_key_object = search_hint.get_string("key_object")
		var hint_value = search_hint.get_string("value")
		var hint_value_object = search_hint.get_string("value_object")

		if hint_value_object :
			if hint_value_object in possible_class_names:
				type_arr = TYPE_OBJECT
				typed_object_type = hint_value_object
			else:
				Helper.throw_error("ERROR: variable uses Object type "+ hint_value_object + " outside of plugin scope")
		elif hint_value.is_valid_int():
			if hint_value.to_int() in TypeManager.SUPPORTED_TYPES:
				type_arr = hint_value.to_int()
			elif hint_value.to_int() == 0:
				type_arr = 0
				#TODO: check if this is alright as a way to handle Variant
				pass
		
		#TODO: implement key this is most copy paste from value for now
		if hint_key_object :
			if hint_key_object in possible_class_names:
				type_arr_key = TYPE_OBJECT
				key_object_name = hint_key_object
			else:
				Helper.throw_error("ERROR: variable uses Object type "+ hint_key_object + " outside of plugin scope")
		elif hint_key.is_valid_int():
			if hint_key.to_int() in TypeManager.SUPPORTED_TYPES:
				type_arr_key = hint_value.to_int()
			elif hint_key.to_int() == 0:
				type_arr_key = 0
		if type_arr:
			disable_select_type_button([type_arr], true, true)
		if type_arr_key:
			key_type = type_arr_key

## Adds a new element to a Dictionary Input
func add_element( value_type: Variant.Type, def_key="", def_input = null):
	var result_dict = create_scene_by_type(value_type)
	var is_vector = result_dict["is_vector"]
	var new_input_node: MultiElementContainer = result_dict["input_node"]
	var new_input_manager: InputManager = result_dict["input_manager"]

	# dictionary values set up
	new_input_node.input_manager = new_input_manager # give the container the manager for the key exchange
	new_input_node.dict_string_default = dict_string_default
	new_input_node.add_key_lineEdit(key_type, key_object_name) # Add lineEdit for entering keys
	new_input_node.remove_move_buttons()
	element_containers.append(new_input_node)
	
	if def_key and not (def_key in get_all_keys()):
		if def_input:
			new_input_manager.receive_input(def_input)
		new_input_node.set_key(def_key) 


func attempt_submit(mute_warnings=false) -> Variant:
	var missing_input_nodes = []
	var return_dict = {}
	var error_object = InputError.new_error_object([])


	for container in element_containers:
		var input_manager = container.input_manager 
		var new_key = container.get_key()
		var value = input_manager.attempt_submit()

		if value is InputError and value.is_ignore():
			continue

		if new_key:
			if new_key in return_dict.keys():
				# TODO: add show input warning for missing key
				missing_input_nodes.append(input_manager)
				Helper.throw_error("ERROR: duplicate keys!")
			if not value is InputError:
				input_manager.hide_input_warning()
				return_dict[new_key] = value
			else:
				missing_input_nodes.append(input_manager)
		else:
			# TODO: call show input warnings in wrong input managers
			input_manager.show_input_warning(InputError.new_error_object(["MISSING_KEY"]))
			missing_input_nodes.append(input_manager)
	
	if missing_input_nodes:
		error_object.toggle_error("INVALID", true)

	return_dict = check_submit_errors(return_dict, error_object)
	#TODO: here might be an issue with IGNORE error_type


	if return_dict is InputError:
		show_input_warning(return_dict)
	return return_dict

func submit_status_dict():
	var value_list = {} # value of the status_dict; Contains all input nodes status_dicts
	for container in element_containers:
		var input_dict = container.input_manager.submit_status_dict()
		var container_key = container.get_key()

		if not container_key or container_key in value_list.keys():
			# TODO: add correct behavior for reaction
			continue
		else:
			value_list[container_key] = input_dict
	
	# if it's a property it has a name, if it's a sub_element like in an array it is empty
	var property_name = property["name"] if property else "" 
	var status_dict = {"value" : value_list, "type" : input_type, "name" : property_name}
	return status_dict

func receive_input(input: Dictionary):
	await self.ready
	for key in input.keys():
		var item_value = input[key]
		if item_value is ObjectWrapper:
			item_value = item_value.obj
		add_element(typeof(item_value), key, item_value)

func get_all_keys() -> Array[String]:
	var key_list: Array[String] = [] as Array[String]
	
	for container in element_containers:
		var key_input = container.get_key()
		if key_input:
			key_list.append(key_input)

	return key_list

func set_input_disabled(is_disabled: bool):
	super(is_disabled)
	for container in element_containers:
		container.set_key_disable(is_disabled)

#region signal_methods

## Removes InputNode from the Dictionary UI
func _on_remove_node(node: MultiElementContainer):
	if node.input.input_type == TYPE_OBJECT and node.input.chosen_wrapper:
		node.input.emit_signal("wrapper_removed", node.input.chosen_wrapper)
	element_containers = element_containers.filter(func(x): return x != node)
	input_managers.remove_at(input_managers.find(node.input))
	on_elements_changed_size()
	multi_input_vbox.remove_child(node)
#endregion
