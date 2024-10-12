@tool
class_name Enums
extends Object
## class for Enums that are not bound to any other class

## possible return types if an input manager is null[br]
## makes it possible to distinguish between Invalid values and Empty values
enum InputErrorType {
	EMPTY,
	INVALID,
	TYPE_INVALID,
	RANGE_INVALID,
	MISSING_KEY,
}

enum InputResponse {
	IGNORE
}