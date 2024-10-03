@tool
class_name ObjectInput
extends InputManager

var property_select: OptionButton
var property_name_label: Label
var class_name_label: Label
var edit_button: Button
var clear_button: TextureButton

var class_loader: ClassLoader

var chosen_wrapper: ObjectWrapper

var wrappers: Array
var class_names: Array
var select_index_to_wrapper: Dictionary

var select_index: int

func initialize_input(property_dict: Dictionary):
	# assign nodes variables
	property_select = get_node("ClassSection/PropterySelect")
	property_name_label = get_node("ClassSection/PropertyName")
	class_name_label = get_node("EditSection/ClassName")
	edit_button = get_node("EditSection/EditButton")
	clear_button = get_node("EditSection/ClearButton")

	property_select.connect("item_selected", Callable(self, "_on_item_selected"))

	# load classes for object select
	# TODO: add integration
	class_loader = ClassLoader.new()
	wrappers = class_loader.return_possible_classes()
	class_names = wrappers.map(func(x): return x.real_class_name if x.real_class_name else Helper.file_name_to_class_name(x.file_class_name))
	
	# set up select class button
	property_name_label.text = property_dict["name"] if property_dict else ""
	for i in class_names.size():
		select_index_to_wrapper[property_select.item_count] = wrappers[i]
		property_select.add_item(class_names[i])
	_on_item_selected(0) # select first item by default so it doesn't just look selected without working

func submit_status_dict():
		var status_dict
		return status_dict


func _on_item_selected(index: int):
	select_index = index
	class_name_label.text = class_names[index]
