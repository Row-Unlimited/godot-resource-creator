class_name TestScript
extends Resource

enum TestEnum {
	NO_TEST,
	TEST
}
## test int
@export var test_int: int
@export var test_string: String ## test string
@export var test_bool: bool
@export var test_vector: Vector3
@export var test_vector_two: Vector3

## test array
@export var test_array: Array
@export var test_typed_array := [1] as Array[int]
@export var test_dict : Dictionary
## test enum [br]
@export var test_enum: TestEnum ## test tooltip functionality
var test_test : int
