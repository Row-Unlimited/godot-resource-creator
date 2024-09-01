@tool
class_name Helper
extends Object

static func check_string_contains_array(stringArray: Array, checkString: String):
	for string: String in stringArray:
		if checkString.contains(string):
			return true
	return false

static func update_object(base_object: Object, update_object: Object, skipped_properties=[], ignore_propery_overflow = false, ignore_null_values = true):
	var new_properties = update_object.get_property_list()
	var old_property_keys = []
	for property in base_object.get_property_list():
		old_property_keys.append(property["name"])

	for property in new_properties:
		
		var property_name = property["name"]
		if property_name in skipped_properties:
			continue
		# check if the property is in the value or if it should be ignored if it isn't
		if not (old_property_keys.has(property_name) or ignore_propery_overflow):
			return null
		
		var update_value = update_object.get(property_name)
		if update_value or not ignore_null_values:
			base_object.set(property_name, update_value)

static func compare_arrays(arr1: Array, arr2: Array, ignore_order=true):
	if arr1.size() != arr2.size():
		return false
	for i in arr1.size():
		if ignore_order:
			if not arr2.has(arr1[i]):
				return false
		else:
			if typeof(arr1[i]) != typeof(arr2[i]):
				return false
			else:
				if arr1[i] != arr2[i]:
					return false
	
	return true

static func print_object_values(obj: Object, skipped_properties=[]):
	var properties = obj.get_property_list()
	for property in properties:
		var property_name = property["name"]
		if property_name in skipped_properties:
			continue
		else:
			var value_string = property_name + ": " + str(obj.get(property_name))
			print(value_string)
			print("--".rpad(value_string.length(), "-"))
