@tool
class_name ConvertJson
extends Object

static func json_parse_levels(json_string: String):
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

	var clean_text = ""

	# remove tabs and whitespaces outside of quotation
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

	# create dictionaries with start/end position and position of sub items (position within the level_dicts array)
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

	var top_level_items = []

	for level_item in level_dicts:
		level_item["bracket_text"] = clean_text.substr(level_item["opening_pos"], level_item["closing_pos"] - level_item["opening_pos"] + 1)
		if "upper_item_pos" not in level_item.keys():
			top_level_items += [level_item]

	return parse_level_items(level_dicts[0], level_dicts)
	
## recursive function that iterates through a level_item dict and parses the json string into godot values
static func parse_level_items(level_item: Dictionary, level_item_arr):
	var return_value
	var bracket_text = level_item["bracket_text"]
	var sub_items = {}
	var sub_count = 0
	var removed_text_number = 0
	for sub_item_pos in level_item["sub_item_positions"]:
		var sub_item = level_item_arr[sub_item_pos]
		var sub_text = sub_item["bracket_text"]
		var find_position = bracket_text.find(sub_text)
		var length_text = sub_item["closing_pos"] - sub_item["opening_pos"] + 1
		if find_position: # issue: need to find clean way to only replace the one correct sub item, currently after the first the others arent detected because position doesnt work anymore
			var item_id = str(sub_count) + "SUB_ITEM"
			var bracketfree_sub_text = sub_text.substr(1, sub_text.length() - 2)
			var text_from_find = bracket_text.substr(find_position, length_text)
			text_from_find = text_from_find.replace(bracketfree_sub_text, item_id)
			bracket_text = bracket_text.replace(sub_text, "")
			bracket_text = bracket_text.insert(find_position, text_from_find)
			sub_items[item_id] = sub_item
			sub_count += 1
			removed_text_number += length_text - 2 - item_id.length()

	var parse_text = bracket_text#.replace("\n", "").replace("\t", "").replace(" ", "")
	parse_text = parse_text.substr(1, parse_text.length() - 2) # remove first and last bracket
	var regex = RegEx.new()
	if bracket_text[0] == "{":
		regex.compile('(\\"\\w+\\"\\:(?:-?\\d+\\.{0,1}\\d*|\\[\\d+SUB_ITEM\\]|\\{\\d+SUB_ITEM\\}|\\"[^\\"]*\\"|(?:true|false)))')
	else:
		regex.compile('(-?\\d+\\.{0,1}\\d*|\\[\\d+SUB_ITEM\\]|\\{\\d+SUB_ITEM\\}|\\"[^\\"]*\\"|(?:true|false))(?:\\,|$)')
	var sub_texts = regex.search_all(parse_text).map(func(x): return x.get_string(1))

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
	
	return return_value

static func parse_raw_json_value(value_string: String):
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
