@tool
class_name ShaderEffectButton
extends TextureButton
## Button that automatically switches shader parameters when certain button events happen [br]
## This happens based on a dictionary export var that the user sets up where for each event they can set a different value[br]
## the keywords for the different states are def/default for the base state that is set at _ready, hov/hovered for when the button is hovered, dis/disabled for when the button is disabled
## down/button_down for when the button is down and up/button_up for when the button is up after pressing
## Structure: [br]
## <parameter name string>: {[br]
##	"default": <value>,[br]
##	"hovered": <value>,[br]
##	"disabled": <value>,[br]
##	"button_down": <value>,[br]
##	"button_down": <value>[br]
##	}[br]

## Dictionary with dictionaries that describe at which point the shader param (first dict key) should be set to
@export var enable_active_checks: bool = true
@export var shader_switch_params: Dictionary

var shader_params

enum ButtonStatus {
	DEFAULT,
	HOVERED,
	DISABLED,
	BUTTON_DOWN,
	BUTTON_UP,
}

func _process(delta: float) -> void:
	if not enable_active_checks:
		return
	if disabled:
		apply_switch_params(ButtonStatus.DISABLED)
		pass
	if is_hovered():
		apply_switch_params(ButtonStatus.HOVERED)

func _ready():
	shader_params = shader_switch_params.duplicate(true)

	if material is ShaderMaterial:
		connect("button_down", _on_button_down)
		connect("button_up", _on_button_up)
		set_up_switch_params()
		apply_switch_params(ButtonStatus.DEFAULT)
	else:
		Helper.throw_error("Shader button has no shader")


func _on_button_up():
	apply_switch_params(ButtonStatus.BUTTON_UP)



func _on_button_down():
	apply_switch_params(ButtonStatus.BUTTON_DOWN)

func set_up_switch_params():
	var shader_param_list = material.shader.get_shader_uniform_list()
	var param_names = shader_param_list.map(func(x): return x["name"])
	var param_dict = {}
	for dict in shader_param_list:
		param_dict[dict["name"]] = dict
	for key in shader_params.keys():
		var switch_dict = shader_params[key]
		if key in param_names:
			var param_type = param_dict[key]["type"]
			for sub_key in switch_dict.keys():
				var switch_value = switch_dict[sub_key]
				var new_key = string_to_status_enum(sub_key) # create new key so accessing is easier if the key is correct
				if typeof(switch_value) == param_type and new_key != null:
					switch_dict[new_key] = switch_value # set value to the new enum key
				switch_dict.erase(sub_key)
					
		else:
			shader_params.erase(key)

func string_to_status_enum(string: String):
	var map_array = [
		["def", "default"],
		["hov", "hovered"],
		["dis", "disabled"],
		["down", "button_down"],
		["up", "button_up"]
	]
	string = string.to_lower()
	var enum_value = null
	for i in map_array.size():
		if string in map_array[i]:
			enum_value = i
			break
	return enum_value

func apply_switch_params(status: ButtonStatus):
	for param_name in shader_params.keys():
		var status_dict = shader_params[param_name]
		if status in status_dict.keys():
			var status_value = status_dict[status]
			material.set_shader_parameter(param_name, status_value)
