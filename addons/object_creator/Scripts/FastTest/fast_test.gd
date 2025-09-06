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
	test_json_parsing()
	
	pass

func test_crap():
	var strings = ["(12, 2, 3, 0)", [0, 1, 2, 3], ["0", 2, 34, "123"]]
	for string in strings:
		print(Helper.custom_to_vector(string, true))
	pass

func json_value_to_gd(value):
	
	pass

func json_parse_levels(json_string: String):
	var level_structure
	
	# iterate through string and write out all bracket location into bracket_dict as array showing levels
	const bracket_types = ["{", "}", "[", "]"]
	const opening_brackets = ["{", "["]
	const closing_brackets = ["}", "]"]
	const closing_to_opening = {"}": "{", "]": "["}
	const REMOVE_CHARS = ["\n", "\t", "\r", " ", ""]
	const quotes_types = ['"', "'"]
	var bracket_array = []
	var current_quotes = ""
	var i = 0
	# added this to clean up before parsing, but now property_configs subsection somehow is missing

	var clean_text = ""

	for char in json_string:
		if char in quotes_types:
			if current_quotes.is_empty():
				current_quotes = char
			elif char == current_quotes:
				current_quotes = ""
		if not current_quotes.is_empty() or not char in REMOVE_CHARS:
			if char in REMOVE_CHARS:
				pass
			clean_text += char
			i += 1

	i = 0
	current_quotes = ""
	for char in clean_text:
		if char in quotes_types:
			if current_quotes.is_empty():
				current_quotes = char
			elif char == current_quotes:
				current_quotes = ""
		if char in bracket_types and current_quotes.is_empty():
			bracket_array.append([char, i])
		i += 1

	var level_dicts = []
	for bracket_info in bracket_array:
		var type = bracket_info[0]
		var pos = bracket_info[1]
		if type in opening_brackets:
			var last_item_pos = level_dicts.rfind_custom(func (x): return x["closing_pos"] == -1)
			var new_level_item = {"type": type, "opening_pos": pos, "closing_pos": -1, "sub_item_positions": []}
			if last_item_pos > -1:
				new_level_item["upper_item_pos"] = last_item_pos
				level_dicts[last_item_pos]["sub_item_positions"].append(level_dicts.size())
			level_dicts.append(new_level_item)
		else:
			var level_item_pos = level_dicts.rfind_custom(func (x): 
				return x["closing_pos"] == -1 and x["type"] == closing_to_opening[type])
			var level_item = level_dicts[level_item_pos]
			level_item["closing_pos"] = pos

	print(bracket_array, "\n\n")

	var top_level_items = []

	for level_item in level_dicts:
		level_item["bracket_text"] = clean_text.substr(level_item["opening_pos"], level_item["closing_pos"] - level_item["opening_pos"] + 1)
		if "upper_item_pos" not in level_item.keys():
			top_level_items += [level_item]
	
	print(top_level_items.size(), "\n\n")

	return parse_level_items(level_dicts[0], level_dicts)

	#return level_dicts
	
func parse_level_items(level_item: Dictionary, level_item_arr):
	var return_value
	var bracket_text = level_item["bracket_text"]
	var sub_items = {}
	var sub_count = 0
	for sub_item_pos in level_item["sub_item_positions"]:
		var sub_item = level_item_arr[sub_item_pos]
		var sub_text = sub_item["bracket_text"]
		var find_position = bracket_text.find(sub_text, sub_item["opening_pos"] - 1)
		var length_text = sub_item["closing_pos"] - sub_item["opening_pos"]
		if find_position: # issue: need to find clean way to only replace the one correct sub item, currently after the first the others arent detected because position doesnt work anymore
			var item_id = str(sub_count) + "SUB_ITEM"
			var text_from_find = bracket_text.substr(find_position, length_text).replace(sub_text.substr(1, sub_text.length() - 2), item_id)
			bracket_text = bracket_text.replace(sub_text, "")
			bracket_text = bracket_text.insert(find_position, text_from_find)
			#bracket_text = bracket_text.replace(sub_text.substr(1, sub_text.length() - 2), item_id)
			sub_items[item_id] = sub_item
			sub_count += 1
		pass

	var parse_text = bracket_text#.replace("\n", "").replace("\t", "").replace(" ", "")
	parse_text = parse_text.substr(1, parse_text.length() - 2) # remove first and last bracket
	var regex = RegEx.new()
	if bracket_text[0] == "{":
		regex.compile('(\\"\\w+\\"\\:(?:\\d+\\.{0,1}\\d*|\\[\\d+SUB_ITEM\\]|\\{\\d+SUB_ITEM\\}|\\"[^\\"]*\\"|(?:true|false)))')
	else:
		regex.compile('(\\d+\\.{0,1}\\d*|\\[\\d+SUB_ITEM\\]|\\{\\d+SUB_ITEM\\}|\\"[^\\"]*\\"|(?:true|false))(?:\\,|$)')
	var sub_texts = regex.search_all(parse_text).map(func(x): return x.get_string())

	print("---> ", sub_texts)

	if bracket_text[0] == "{":
		return_value = {}
		sub_texts = sub_texts.map(func(x): return x.split("\":"))
		for sub_parts in sub_texts:
			var key = sub_parts[0]
			key = key.replace("\"", "")
			var value = sub_parts[1]
			if value.begins_with("{") or value.begins_with("["):
				var sub_item = sub_items[value.substr(1, value.length() - 2)]
				value = parse_level_items(sub_item, level_item_arr)
			else:
				value = parse_raw_json_value(value)
			return_value[key] = value
	else:
		return_value = []
		for value in sub_texts:
			if value.begins_with("{") or value.begins_with("["):
				var sub_item = sub_items[value.substr(1, value.length() - 2)]
				value = parse_level_items(sub_item, level_item_arr)
			else:
				value = parse_raw_json_value(value)
			return_value.append(value)
	if not "upper_item_pos" in level_item.keys():
		pass
	print("\n+++> ", return_value)
	
	return return_value

func parse_raw_json_value(value_string: String):
	if value_string.begins_with("\""):
		return value_string.replace("\"", "")
	elif value_string.contains(".") and value_string.is_valid_float():
		return value_string.to_float()
	elif value_string.is_valid_int():
		return value_string.to_int()
	elif value_string.contains("true"):
		return true
	elif value_string.contains("false"):
		return false
	else:
		return null

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

	var json_string = FileAccess.get_file_as_string("res://addons/object_creator/ClassConfigs/class_config.json")
	print(json_parse_levels(json_string))

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
