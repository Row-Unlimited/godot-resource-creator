@tool
class_name ObjectInput
extends InputManager

signal edit_sub_object_clicked(wrapper: ObjectWrapper, object_input: ObjectInput)
signal choose_class_button_clicked(wrapper: ObjectWrapper, object_input: ObjectInput)

var property_select: OptionButton
var property_name_label: Label
var property_type_label: Label
var class_name_label: Label
var choose_class_button: TextureButton
var edit_button: Button
var clear_button: TextureButton

var class_loader: ClassLoader
var object_create_screen: CreateObject

var chosen_wrapper: ObjectWrapper
var parent_wrapper: ObjectWrapper

var wrappers: Array
var class_names: Array = []
var select_index_to_wrapper: Dictionary

var select_index: int

var status_dict: Dictionary

func initialize_input(property_dict: Dictionary):
	property = property_dict
	input_type = TYPE_OBJECT


	# assign nodes variables
	property_select = get_node("ClassSection/PropterySelect")
	property_name_label = get_node("ClassSection/PropertyName")
	property_type_label = get_node("ClassSection/PropertyType")
	class_name_label = get_node("EditSection/ClassName")
	choose_class_button = get_node("ClassSection/ChooseClassButton")
	edit_button = get_node("EditSection/EditButton")
	clear_button = get_node("EditSection/ClearButton")

	property_select.connect("item_selected", Callable(self, "_on_item_selected"))
	choose_class_button.connect("pressed", Callable(self, "_on_choose_class_button_clicked"))
	edit_button.connect("pressed", Callable(self, "_on_edit_button_clicked"))
	clear_button.connect("pressed", Callable(self, "_on_clear_button_clicked"))
	if property_dict:
		property_type_label.text = property_dict["class_name"]

	# load classes for object select
	# TODO: add integration
	class_loader = ClassLoader.new()
	wrappers = class_loader.return_possible_classes()

	var wrong_wrappers = []

	for i in wrappers.size():
		var wrapper = wrappers[i]
		var wrapper_obj = Helper.create_null_instance(load(wrapper.path))
		#var wrapper_obj = load(wrapper.path).new()
		var wrapper_name = wrapper_obj.get_script().get_global_name()
		if property_dict["class_name"] == wrapper_name or wrapper_obj.is_class(property_dict["class_name"]):
			class_names.append(wrapper.real_class_name if wrapper.real_class_name else Helper.file_name_to_class_name(wrapper.file_class_name))
		else:
			wrong_wrappers.append(i)
	
	wrong_wrappers.sort()
	wrong_wrappers.reverse()
	for pos in wrong_wrappers:
		wrappers.remove_at(pos)

	#class_names = wrappers.map(func(x): return x.real_class_name if x.real_class_name else Helper.file_name_to_class_name(x.file_class_name))
	
	# set up select class button
	if "name" in property_dict.keys():
		property_name_label.text = property_dict["name"] if property_dict else ""
	
	for i in class_names.size():
		var class_option = class_names[i]
		select_index_to_wrapper[property_select.item_count] = wrappers[i]
		if class_option:
			pass
		property_select.add_item(class_names[i])
	_on_item_selected(0) # select first item by default so it doesn't just look selected without working

	if property_select.item_count == 1:
		# automatically select the class if there is only one possible class
		_on_choose_class_button_clicked()
		clear_button.disabled = true

func attempt_submit(mute_warnings=false):
	var return_value = null
	if object_create_screen:
		return_value = object_create_screen.on_submit_pressed()
	
	if return_value == null or return_value is InputError:
		# TODO: implement actual response to return_value giving you an error
		return_value = return_empty_value()

	return return_value

## receives an input for the create_object screen
## when editing, the input is the created object not a wrapper
func receive_input(input):
	if typeof(input) == TYPE_OBJECT:
		var input_class_name = input.get_script().get_global_name()
		if input_class_name in class_names:
			for i in property_select.item_count:
				if property_select.get_item_text(i) == input_class_name:
					property_select.select(i)
					select_index = i
					select_index_to_wrapper[i].obj = input
					_on_choose_class_button_clicked()
					
	else:
		assert(false, "ERROR: NON OBJECT CANNOT BE RECEIVED AS INPUT FOR OBJECT INPUT")

func submit_status_dict():
	var new_status_dict = {
		"name": property["name"] if "name" in property.keys() else "",
		"value": chosen_wrapper.id if chosen_wrapper else "",
		"type": input_type
	}
	return new_status_dict

func hide_input_warning():
	pass

#region signal_methods
func _on_item_selected(index: int):
	select_index = index
	class_name_label.text = class_names[index]

func set_up_nodes():
	pass

func _on_choose_class_button_clicked():
	chosen_wrapper = select_index_to_wrapper[select_index]
	chosen_wrapper.parent_wrapper = parent_wrapper
	choose_class_button.disabled = true
	property_select.disabled = true
	emit_signal("choose_class_button_clicked", chosen_wrapper, self)

func _on_edit_button_clicked():
	if chosen_wrapper:
		emit_signal("edit_sub_object_clicked", chosen_wrapper, self)
	else:
		# TODO: add warning if no class was selected yet
		pass

func _on_clear_button_clicked():
	chosen_wrapper = null
	choose_class_button.disabled = false
	property_select.disabled = false
#endregion
