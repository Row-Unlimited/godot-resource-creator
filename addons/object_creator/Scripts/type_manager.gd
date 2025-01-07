class_name TypeManager
extends Node

const SUPPORTED_TYPES = [
	TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING,
	TYPE_OBJECT, TYPE_ARRAY, TYPE_DICTIONARY,
	TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I,
	]

const VECTOR_TYPES = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]

const TYPE_GROUPS = [
	[TYPE_BOOL, "bool", "TYPE_BOOL", false],
	[TYPE_INT, "int", "TYPE_INT", 0],
	[TYPE_FLOAT, "float", "TYPE_FLOAT", 0],
	[TYPE_STRING, "String", "TYPE_STRING", ""],
	[TYPE_VECTOR2, "Vector2", "TYPE_VECTOR2", Vector2(0, 0)],
	[TYPE_VECTOR2I, "Vector2i", "TYPE_VECTOR2I", Vector2i(0, 0)],
	[TYPE_VECTOR3, "Vector3", "TYPE_VECTOR3", Vector3(0, 0, 0)],
	[TYPE_VECTOR3I, "Vector3i", "TYPE_VECTOR3I", Vector3i(0, 0, 0)],
	[TYPE_VECTOR4, "Vector4", "TYPE_VECTOR4", Vector4(0, 0, 0, 0)],
	[TYPE_VECTOR4I, "Vector4i", "TYPE_VECTOR4I", Vector4i(0, 0, 0, 0)],
	[TYPE_DICTIONARY, "Dictionary", "TYPE_DICTIONARY", {}],
	[TYPE_ARRAY, "Array", "TYPE_ARRAY", []],
	[TYPE_OBJECT, "Object", "TYPE_OBJECT", null]
]

const INPUT_SCENES = {
	"default": "res://addons/object_creator/Scenes/Variable Input Scenes/default_input.tscn",
	"bool": "res://addons/object_creator/Scenes/Variable Input Scenes/bool_input.tscn",
	"vector": "res://addons/object_creator/Scenes/Variable Input Scenes/vector_input.tscn",
	"array": "res://addons/object_creator/Scenes/Variable Input Scenes/array_input.tscn",
	"dictionary": "res://addons/object_creator/Scenes/Variable Input Scenes/dictionary_input.tscn",
	"object": "res://addons/object_creator/Scenes/Variable Input Scenes/object_input.tscn",
}

enum TypeValue {
	TYPE_ENUM,
	READ_STRING,
	TYPE_ENUM_STRING,
	EMPTY_VALUE,
}

static func find_type_value(value, return_type = -1):
	var return_group = ""
	if value in MAPPING_KEYS:
		return_group = TYPE_MAPPING[value]
		if return_type != -1 and return_type <= return_group.size():
			return return_group[return_type]
	
	return return_group

static func get_all_values(return_type: TypeValue):
	return TYPE_GROUPS.map(func(x): return x[return_type])

static func get_input_scene(input_type: Variant.Type):
	var new_scene
	match input_type:
		TYPE_INT:
			new_scene = INPUT_SCENES["default"]
		TYPE_FLOAT:
			new_scene = INPUT_SCENES["default"]
		TYPE_STRING:
			new_scene = INPUT_SCENES["default"]
		TYPE_BOOL:
			new_scene = INPUT_SCENES["bool"]
		TYPE_ARRAY:
			new_scene = INPUT_SCENES["array"]
		TYPE_DICTIONARY:
			new_scene = INPUT_SCENES["dictionary"]
		TYPE_OBJECT:
			new_scene = INPUT_SCENES["object"]
		_:
			if VECTOR_TYPES.has(input_type):
				new_scene = INPUT_SCENES["vector"]
	new_scene = load(new_scene)
	return new_scene

const TYPE_MAPPING = {
	TYPE_BOOL: [TYPE_BOOL, "bool", "TYPE_BOOL", false],
	"bool": [TYPE_BOOL, "bool", "TYPE_BOOL", false],
	"TYPE_BOOL": [TYPE_BOOL, "bool", "TYPE_BOOL", false],

	TYPE_INT: [TYPE_INT, "int", "TYPE_INT", 0],
	"int": [TYPE_INT, "int", "TYPE_INT", 0],
	"TYPE_INT": [TYPE_INT, "int", "TYPE_INT", 0],

	TYPE_FLOAT: [TYPE_FLOAT, "float", "TYPE_FLOAT", 0],
	"float": [TYPE_FLOAT, "float", "TYPE_FLOAT", 0],
	"TYPE_FLOAT": [TYPE_FLOAT, "float", "TYPE_FLOAT", 0],

	TYPE_STRING: [TYPE_STRING, "String", "TYPE_STRING", ""],
	"String": [TYPE_STRING, "String", "TYPE_STRING", ""],
	"TYPE_STRING": [TYPE_STRING, "String", "TYPE_STRING", ""],

	TYPE_VECTOR2: [TYPE_VECTOR2, "Vector2", "TYPE_VECTOR2", Vector2(0, 0)],
	"Vector2": [TYPE_VECTOR2, "Vector2", "TYPE_VECTOR2", Vector2(0, 0)],
	"TYPE_VECTOR2": [TYPE_VECTOR2, "Vector2", "TYPE_VECTOR2", Vector2(0, 0)],

	TYPE_VECTOR2I: [TYPE_VECTOR2I, "Vector2i", "TYPE_VECTOR2I", Vector2i(0, 0)],
	"Vector2i": [TYPE_VECTOR2I, "Vector2i", "TYPE_VECTOR2I", Vector2i(0, 0)],
	"TYPE_VECTOR2I": [TYPE_VECTOR2I, "Vector2i", "TYPE_VECTOR2I", Vector2i(0, 0)],

	TYPE_VECTOR3: [TYPE_VECTOR3, "Vector3", "TYPE_VECTOR3", Vector3(0, 0, 0)],
	"Vector3": [TYPE_VECTOR3, "Vector3", "TYPE_VECTOR3", Vector3(0, 0, 0)],
	"TYPE_VECTOR3": [TYPE_VECTOR3, "Vector3", "TYPE_VECTOR3", Vector3(0, 0, 0)],

	TYPE_VECTOR3I: [TYPE_VECTOR3I, "Vector3i", "TYPE_VECTOR3I", Vector3i(0, 0, 0)],
	"Vector3i": [TYPE_VECTOR3I, "Vector3i", "TYPE_VECTOR3I", Vector3i(0, 0, 0)],
	"TYPE_VECTOR3I": [TYPE_VECTOR3I, "Vector3i", "TYPE_VECTOR3I", Vector3i(0, 0, 0)],

	TYPE_VECTOR4: [TYPE_VECTOR4, "Vector4", "TYPE_VECTOR4", Vector4(0, 0, 0, 0)],
	"Vector4": [TYPE_VECTOR4, "Vector4", "TYPE_VECTOR4", Vector4(0, 0, 0, 0)],
	"TYPE_VECTOR4": [TYPE_VECTOR4, "Vector4", "TYPE_VECTOR4", Vector4(0, 0, 0, 0)],

	TYPE_VECTOR4I: [TYPE_VECTOR4I, "Vector4i", "TYPE_VECTOR4I", Vector4i(0, 0, 0, 0)],
	"Vector4i": [TYPE_VECTOR4I, "Vector4i", "TYPE_VECTOR4I", Vector4i(0, 0, 0, 0)],
	"TYPE_VECTOR4I": [TYPE_VECTOR4I, "Vector4i", "TYPE_VECTOR4I", Vector4i(0, 0, 0, 0)],

	TYPE_DICTIONARY: [TYPE_DICTIONARY, "Dictionary", "TYPE_DICTIONARY", {}],
	"Dictionary": [TYPE_DICTIONARY, "Dictionary", "TYPE_DICTIONARY", {}],
	"TYPE_DICTIONARY": [TYPE_DICTIONARY, "Dictionary", "TYPE_DICTIONARY", {}],

	TYPE_ARRAY: [TYPE_ARRAY, "Array", "TYPE_ARRAY", []],
	"Array": [TYPE_ARRAY, "Array", "TYPE_ARRAY", []],
	"TYPE_ARRAY": [TYPE_ARRAY, "Array", "TYPE_ARRAY", []],

	TYPE_OBJECT: [TYPE_OBJECT, "Object", "TYPE_OBJECT", null],
	"Object": [TYPE_OBJECT, "Object", "TYPE_OBJECT", null],
	"TYPE_OBJECT": [TYPE_OBJECT, "Object", "TYPE_OBJECT", null]
}

const MAPPING_KEYS = [
	TYPE_BOOL, "bool", "TYPE_BOOL",
	TYPE_INT, "int", "TYPE_INT",
	TYPE_FLOAT, "float", "TYPE_FLOAT",
	TYPE_STRING, "String", "TYPE_STRING",
	TYPE_VECTOR2, "Vector2", "TYPE_VECTOR2",
	TYPE_VECTOR2I, "Vector2i", "TYPE_VECTOR2I",
	TYPE_VECTOR3, "Vector3", "TYPE_VECTOR3",
	TYPE_VECTOR3I, "Vector3i", "TYPE_VECTOR3I",
	TYPE_VECTOR4, "Vector4", "TYPE_VECTOR4",
	TYPE_VECTOR4I, "Vector4i", "TYPE_VECTOR4I",
	TYPE_DICTIONARY, "Dictionary", "TYPE_DICTIONARY",
	TYPE_ARRAY, "Array", "TYPE_ARRAY",
	TYPE_OBJECT, "Object", "TYPE_OBJECT"
]
