extends Control

@onready var label: Label = $Label

# On process, if visible, move the label to the mouse position
func _process(_delta):
	if visible:
		position = get_global_mouse_position()

# Displays pattern info for a given p_code (Starts with "P" for pattern/p_code)
# Displays entity info for a given entity (Starts with "E" for entity) # Not implemented at all right now
# Displays error message for given error (Starts with "B" for bad_iota)
func display(meta: String):
	visible = true
	# Split meta into parts: First part is type, the first character. Second part is the rest of the string
	var type = meta[0]
	var rest = meta.substr(1)
	if type == "P":
		label.text = "Pattern: " + rest
	# elif type == "E":
	# 	label.text = "Entity: " + rest
	elif type == "B":
		label.text = "Error: " + rest
	else:
		label.text = "Unknown: " + meta
	
# Hides the label
func stop_display():
	visible = false