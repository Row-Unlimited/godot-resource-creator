@tool
class_name CreationWindow
extends Control

enum WindowType {
	CREATE_OBJECT,
	PATH_CHOICE,
	CLASS_CHOICE
}

var window_type : WindowType
var session_dict : Dictionary

func save_session():
	pass

func load_session(session_dict: Dictionary):
	pass
