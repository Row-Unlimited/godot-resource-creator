class_name InputError
extends Object

enum ErrorType {
	IGNORE,
	EMPTY,
	INVALID,
	TYPE_INVALID,
	RANGE_INVALID,
	MISSING_KEY,
	OBJECT_INVALID,
}
const error_type_string = ["IGNORE", "EMPTY","INVALID","TYPE_INVALID","RANGE_INVALID","MISSING_KEY","OBJECT_INVALID"]

var errors: Array[ErrorType] = []


static func new_error_object(error_types = []):
	var new_object = InputError.new()
	error_types = error_types.filter(func(x): return x is ErrorType or x is String)
	error_types = error_types.map(func(x): return x if x is ErrorType else to_error_type(x))
	new_object.errors.assign(error_types)
	return new_object

static func to_error_type(value):
	if value is String and value in error_type_string:
		return ErrorType.values()[error_type_string.find(value)]
	elif value is ErrorType:
		return value
	else:
		return ErrorType.IGNORE
	

func toggle_error(error, ONE_WAY_TOGGLE = false):
	if error is String:
		error = to_error_type(error)
	elif not error is ErrorType:
		return
	
	if error in errors:
		if ONE_WAY_TOGGLE:
			return
		errors.remove_at(errors.find(error))
	else:
		errors.append(error)

func has_any_errors(ignored_errors: Array = []):
	if ignored_errors:
		ignored_errors = ignored_errors.map(to_error_type)

	ignored_errors = [ErrorType.IGNORE] + ignored_errors
	return errors.any(func(x): return x is ErrorType and not x in ignored_errors)

func has_error(error, HAS_ONLY = false):
	error = to_error_type(error)
	if HAS_ONLY:
		# checks if errors is empty without the specified error
		return errors.filter(func(x): return x != error).is_empty() and error in errors
	else:	
		return error in errors

func is_ignore():
	return has_error("IGNORE", true)
