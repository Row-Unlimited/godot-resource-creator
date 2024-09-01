@tool
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#test_helper_compare()
	#test_helper_update()
	test_crap()

func test_crap():
	var test_obj = TestClass.new()
	for property in test_obj.get_property_list():
		print(property)

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

func test_helper_compare():
	var a1 = [1,"2",3.]
	var a2 = [1, 3., "2"]
	var a3 = ["bleh", "2"]
	print(Helper.compare_arrays(a1, a2)) # true
	print(Helper.compare_arrays(a1, a2, false)) # false
	print(Helper.compare_arrays(a1, a3)) # false
	



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
