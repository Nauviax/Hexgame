extends Control

@export var title_label: Label
@export var code_label: Label
@export var is_spell_label: Label
@export var iota_count_label: Label

@export var middle_container: Control
@export var description_label: Label
@export var background: NinePatchRect

# Reference to the currently displayed pattern, if displaying one. Should be cleared on stop_display()
var current_pattern: Pattern = null

# On first process after being shown, set size to 0 to force refit container
var first_process = false

# Onready, hide
func _ready():
	visible = false	

# On process, if visible, move to the mouse position
func _process(_delta):
	if visible:
		position = get_global_mouse_position()
		if first_process: # Refit container on first process
			first_process = false
			size.y = 0

# Displays pattern info for a given p_code (Starts with "P" for pattern/p_code)
# Displays entity info for a given entity (Starts with "E" for entity) # Not implemented at all right now
# Displays error message for given error (Starts with "B" for bad_iota)
func display(meta: String):
	# Split meta into parts: First part is type, the first character. Second part is the rest of the string
	var type = meta[0]
	var rest = meta.substr(1)
	if type == "P": # Pattern
		if current_pattern == null or rest != current_pattern.p_code: # If the p_code is different, refresh contents
			middle_container.visible = true # Used for pattern info
			current_pattern = Pattern.new(rest) # Create a new pattern with the given p_code
			var p_name = current_pattern.name
			title_label.text = p_name
			if p_name == "Numerical Reflection":
				title_label.text += " | " + str(current_pattern.value)
			elif p_name == "Bookkeeper's Gambit":
				title_label.text += " | " + Pattern.value_to_bookkeeper(current_pattern.value)
			code_label.text = current_pattern.p_code
			is_spell_label.text = "Spell" if current_pattern.p_exe.is_spell else "Pattern"
			iota_count_label.text = "Iotas In: " + str(current_pattern.p_exe.iota_count)
			description_label.text = "Desc NYI"
	else: # Non-patterns get less info shown
		middle_container.visible = false
		if type == "B": # Error (E reserved for entities, possibly change later (!!!))
			title_label.text = "Error"
			description_label.text = rest
		else:
			title_label.text = "Unknown"
			description_label.text = meta
	# Show self
	visible = true
	first_process = true

# Hide self
func stop_display():
	visible = false
	# current_pattern = null # Don't clear last used pattern, but keep it so it doesn't have to be reloaded if the same pattern is displayed again
