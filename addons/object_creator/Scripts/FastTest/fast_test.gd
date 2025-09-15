@tool
class_name FastTest
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#test_error()
	#test_helper_compare()
	#test_helper_update()
	#test_crap()
	#test_better_print()
	#test_json()
	#test_tab_bar()
	#test_dict_merge()
	#test_doc_format()
	#test_scaling()
	#test_json_parsing()
	
	pass

func test_crap():
	var strings = ["(12, 2, 3, 0)", [0, 1, 2, 3], ["0", 2, 34, "123"]]
	for string in strings:
		print(Helper.custom_to_vector(string, true))
	pass

func test_json_parsing():
	var test_dict = {
		"example_int": 1, "example_float": 0.4, "example_float_int": 3.0,
		"example_array": [1, 0.4, [1, 0.4, "test"]],
		"example_dict": {"test": "test", "test1": [1, 0.0]},
		"example_vector": Vector2(1, 2)
		}
	var stringified_normal = JSON.stringify(test_dict)
	print(stringified_normal, "\n")
	var encoded = JSON.stringify(JSON.from_native(test_dict, false))
	print(encoded, "\n")
	var decoded = JSON.to_native(JSON.parse_string(encoded), false)
	print(decoded, "\n")
	print(JSON.parse_string(stringified_normal), "\n")
	var json_to_gd = ConvertJson.json_parse_levels(stringified_normal)
	print("++>", stringified_normal, "\n")
	print("-->", json_to_gd, "\n\n")

	var json_string = FileAccess.get_file_as_string("res://addons/object_creator/ClassConfigs/class_config.json")
	print(ConvertJson.json_parse_levels(json_string))

func test_doc_format():
	var test_string_newline = ["## test string [br]", "## test string 2"]
	print(Helper.format_doc_strings(test_string_newline))

func test_error():
	var obj = InputError.new_error_object(["OBJECT_INVALID", InputError.ErrorType.EMPTY])
	print(obj.errors)

func test_json():
	var object: TestScript = TestScript.new()
	object.testArray = ["1", 34]
	print(Helper.to_printable_str(Helper.object_to_dict(object)))

func test_helper_update():
	var test_object_1 = TestClass.new()
	var test_object_2 = TestClass.new()
	test_object_2.test_int = 0
	test_object_2.test_string = "hello, I am new"
	test_object_2.test_array.remove_at(0)
	
	Helper.update_object(test_object_1, test_object_2, ["test_string"])
	
	test_object_1.print_me()
	print("--------------------------------")
	test_object_2.print_me()

func test_scaling():
	var obj = ScaleAssistant.new()
	obj.scale_node = get_parent().get_child(0)
	pass

func test_dict_merge():
	var base_dict = {"test": {"test1": 10, "test2":20}}
	var test_dict = {"test": {"test1":5}}
	var base_double = base_dict.duplicate(true)
	base_double.merge(test_dict, true)
	print(base_double)

	print(Helper.dictionary_merge_deep(base_dict, test_dict))
	print(Helper.dictionary_merge_deep(base_dict, test_dict, true))

	pass

func test_tab_bar():
	var tab_bar = TabBar.new()
	for i in 5:
		tab_bar.add_tab(str(i))
	
	for i in 10:
		tab_bar.move_tab(randi_range(0,4), 0)
		var order = "order is: "
		for j in 5:
			order += tab_bar.get_tab_title(j) + " at position " + str(j) + ", "
		print(order)

func test_helper_compare():
	var a1 = [1,"2",3.]
	var a2 = [1, 3., "2"]
	var a3 = ["bleh", "2"]
	print(Helper.compare_arrays(a1, a2)) # true
	print(Helper.compare_arrays(a1, a2, false)) # false
	print(Helper.compare_arrays(a1, a3)) # false
	

func test_better_print():
	var test = [1, 2, 3, ["aldsjflkasjdfjdksalf", "lajdslfjldj"], "aldsjflkdjfjdf", 288888888888888]
	var test_dict_print = {"test": 1, "hello": "ljasdlkfjaldsfljfd", "array": test, "dict": {"alsdjfkldjfkjjf": "alsdjflkdjfkjdf", "heyho": 90876}}
	print(Helper.to_printable_str(test_dict_print))


class TestClass:
	var test_string : String = "test"
	var test_int : int = 123
	var test_array : Array = [1,"2",3.]
	var myArray := [] as Array[int]
	var test_dict : Dictionary = {
		"value_one": 1,
		"value_two": "2",
		"value_three": 3.
	}
	func print_me():
		print("test string: " + test_string)
		print("test int: " + str(test_int))
		print("test array: " + str(test_array))
		print("test dictionary: " + str(test_dict))
