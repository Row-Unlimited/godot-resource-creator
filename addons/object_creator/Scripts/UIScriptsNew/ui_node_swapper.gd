@tool
class_name UiNodeSwapper
extends Control

enum SignalMode {
	ATTACH,
	REMOVE,
	TOGGLE,
	HIDE,
	SHOW,
}

const MODE_FUNCTION_MAPPING = {
	SignalMode.ATTACH: "attach_node_to_screen",
	SignalMode.REMOVE: "",
	SignalMode.TOGGLE: "",
	SignalMode.HIDE: "",
	SignalMode.SHOW: ""
}

## counts each created tab, to create unique IDs for every tab
var counter = 0
## dict that maps ids to index
var node_mapping: Dictionary

## dict that maps ids to screen_nodes
var screen_mapping: Dictionary

## maps nodes to screens, and is used to keep track of where a node is connected to
var connection_mapping: Dictionary

## if not further specified, connections will be applied to this node.
## if no default screen is defined in swapper_set_up the swapper will use itself
var default_screen: Control

## Where the user is hovering over. -1 if they are hovering above nothing
var hover_target: int

## sets up the swapper
func swapper_set_up(default_screen_node: Control = self):
	default_screen = default_screen_node


func attach_node_to_screen(swap_id, screen_id=null, override_disabled=false):
	if swap_id in node_mapping.keys():
		var node = node_mapping[swap_id]
		var screen = screen_mapping[screen_id] if screen_id in screen_mapping.keys() else default_screen
		if screen.get_children() and not override_disabled:
			for child in screen.get_children():
				child.visibile = false
		screen.add_child(node)
		connection_mapping[swap_id] = connection_mapping[swap_id] + [screen] if swap_id in connection_mapping else [screen]
	else:
		assert(false, "no id for this index")

## Will remove a node of a certain from either all screens(when screen_id = null) or from one specific screen
func remove_node(swap_id, screen_id = null, show_hidden = false):
	if not swap_id in node_mapping.keys():
		assert(false, "CREATECONNECTION-ERROR: SWAP_NODE IS NULL")
	var swap_node = node_mapping[swap_id]
	var screens: Array[Control]
	if screen_id:
		screens = get_screen(screen_id)
	else:
		# gets all screens the swap_node is connected to by id
		screens = connection_mapping[swap_id]
	
	for screen in screens:
		screen.remove_child(swap_node)
		if show_hidden:
			for child: Control in screen.get_children():
				child.visible = true

	connection_mapping[swap_id] = connection_mapping[swap_id].filter(func(item): return (not item in screens)) 	# update connection_mapping


func toggle_node(swap_id, screen_id = null):
	if not swap_id in node_mapping.keys():
		assert(false, "CREATECONNECTION-ERROR: SWAP_NODE IS NULL")
	var swap_node = node_mapping[swap_id]
	swap_node.visible = false if swap_node.visible else true

func show_node(swap_id):
	if not swap_id in node_mapping.keys():
		assert(false, "CREATECONNECTION-ERROR: SWAP_NODE IS NULL")
	var swap_node = node_mapping[swap_id]
	swap_node.visible = true

func hide_node(swap_id, screen_id = null):
	if not swap_id in node_mapping.keys():
		assert(false, "CREATECONNECTION-ERROR: SWAP_NODE IS NULL")
	var swap_node = node_mapping[swap_id]
	swap_node.visible = false


## adds a new swap_node that can be swapped, removed etc. with the id and functions [br]
## [param id] must be unique [br]
## [param signal_information] can be used to connect a signal to function activation if needed.
## For this you must give a dictionary with signal_name, signal_object and the signal_mode,
## meaning which functionality you want to connect it to. [br]
## The signal must necessarily have the parameters that the function in question needs
func add_new_connection(id, swap_node: Control, signal_information: Dictionary = {}, override_key = false):
	if not swap_node:
		assert(false, "CREATECONNECTION-ERROR: SWAP_NODE IS NULL")
	if id in node_mapping.keys() and not override_key:
		assert(false, "CREATECONNECTION-ERROR: ID ALREADY EXISTS IN CONNECTION MAPPING")
	node_mapping[id] = swap_node

	if signal_information:
		var signal_obj = signal_information["obj"]
		var signal_name = signal_information["signal_name"]
		var signal_mode = signal_information["mode"]
		if signal_obj and signal_name and signal_obj.has_signal(signal_name):
			signal_obj.connect(signal_name, Callable(self, MODE_FUNCTION_MAPPING[signal_mode]))

func add_new_screen(id, screen_node: Control, override_key = false):
	if not screen_node:
		assert(false, "CREATECONNECTION-ERROR: SCREEN_NODE IS NULL")
	if id in screen_mapping.keys() and not override_key:
		assert(false, "CREATECONNECTION-ERROR: ID ALREADY EXISTS IN SCREEN MAPPING")
	else:
		screen_mapping[id] = screen_node

func get_screen(id):
	return screen_mapping[id] if id in screen_mapping.keys() else default_screen
