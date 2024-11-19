class_name ConstructorTest
extends Resource

@export var test_int: int
@export var test_int_varname: int
@export var test_array: Array

func _init(a: int, b: int, c: Array = [], comma_test: Vector2 = Vector2(1, 2)) -> void:
	test_int = a
	test_int_varname = b
	test_array = c
