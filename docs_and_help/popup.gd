extends Control
class_name Hex_Popup

@export var title_label: Label
@export var code_label: Label
@export var is_spell_label: Label
@export var iota_count_label: Label

@export var middle_container: Control
@export var graphic_parent: Control
@export var desc_button: Button # Grey out when < 2 descs
@export var description_label: RichTextLabel
@export var background: NinePatchRect

# Reference to the popup scene to create new instances
static var popup_scene: PackedScene = preload("res://docs_and_help/popup.tscn")

# Reference to the currently displayed pattern, if displaying one.
var current_pattern: Pattern = null

# Last shown description page for pattern, so same description is shown on repeat hovers.
var desc_page: int = 0

# On first process after being shown, set size to 0 to force refit container
var first_process: bool = false

# If true, show the popup above mouse instead of below
var show_above: bool = false

# If true, the popup is locked in place and won't close unless manually done so
var locked_display: bool = false # Prevent hiding and changing display contents (Should never be reset to false once true)
var locked_movement: bool = false # Prevent following mouse

# Creates a new popup, has parent adopt it, and returns it.
static func make_new(parent: Control) -> Hex_Popup:
	var popup: Hex_Popup = popup_scene.instantiate()
	parent.add_child(popup)
	return popup

# Onready, hide
func _ready() -> void:
	visible = false
	var hex_display: Hex_Display = get_parent().get_parent() # This is an assumption that probably isn't very safe long-term, but should work for now. (!!!)
	description_label.meta_hover_started.connect(hex_display._on_meta_hover_started)
	description_label.meta_hover_ended.connect(hex_display._on_meta_hover_ended)
	description_label.meta_clicked.connect(hex_display._on_meta_clicked)

# On process, if visible and not locked, move to the mouse position
func _process(_delta: float) -> void:
	if visible:
		if not locked_movement:
			update_position()
		if first_process: # Refit container on first process
			first_process = false
			size.x = 0
			size.y = 0

# Updates popup position
func update_position() -> void:
	# Offset away from mouse to avoid overlap, offset upwards by size if showing above, and offset towards top left if locked (Dragging)
	position = get_global_mouse_position() + Vector2(5, (-5-background.size.y) if show_above else 5.0) - (Vector2(30, 30) if locked_display else Vector2.ZERO)

# Displays pattern info for a given p_code (Starts with "P" for pattern/p_code)
# Displays error message for given error (Starts with "E" for error)
# Displays plain text (Starts with "M" for message)
func display(meta: String, show_above: bool = false) -> void:
	if locked_display: # If locked, don't change display and throw an error (Should never happen, but just in case)
		printerr("WARNING: Attempted to update display of a locked popup.")
		return
	self.show_above = show_above
	# Split meta into parts: First part is type, the first character. Second part is the rest of the string
	var type: String = meta[0]
	var rest: String = meta.substr(1)
	if type == "P": # Pattern
		if current_pattern == null or rest != current_pattern.p_code: # If the p_code is different, refresh contents
			middle_container.visible = true # Used for pattern info
			current_pattern = Pattern.new(rest) # Create a new pattern with the given p_code

			title_label.text = current_pattern.name_display

			code_label.text = current_pattern.p_code
			is_spell_label.text = "Spell" if current_pattern.is_spell else "Pattern"
			iota_count_label.text = "Iotas In: " + str(current_pattern.p_exe_iota_count)
			desc_page = 0 # Reset page if new pattern

			set_description(current_pattern.descs[0])
			if current_pattern.descs.size() > 1: # Disable button if only one description
				desc_button.disabled = false
			else:
				desc_button.disabled = true

			var pattern_line: Line2D = Pattern.create_line(current_pattern.p_code)
			if graphic_parent.get_child_count() != 0: # Remove old graphic if exists
				graphic_parent.get_child(0).queue_free()
			graphic_parent.add_child(pattern_line) # Add new graphic
	else: # Non-patterns get less info shown
		current_pattern = null # Clear current pattern
		middle_container.visible = false
		match type:
			"E": # Error
				title_label.text = "Error"
				set_description(rest)
			"L": # List, decode square brackets and display fairly normally.
				title_label.text = "List"
				set_description(rest.replace("BBCODELEFT", "[").replace("BBCODERIGHT", "]"))
			"M": # Message, basically plain text
				title_label.text = "Message"
				set_description(rest)
			_: # Default to unknown, shouldn't happen
				title_label.text = "Unknown"
				set_description(meta)
	# Show self
	update_position()
	visible = true
	first_process = true

# Special function for setting description text, as it uses a richtextlabel.
# For now it just adds [centre] tags. Later, (!!!) I want to set min_size_y to the height of desc_label, capped at 200px or similar. I'm yet to get this to work however.
func set_description(text: String) -> void:
	description_label.text = "[center]" + text
	# description_label.custom_minimum_size.y = min(100, description_label.get_content_height()) # There is no max size option in Godot, so we simulate it basically.

# Lock self, preventing it from following mouse or changing content.
func lock() -> void:
	visible = true # Ensure popup will never be locked while hidden somehow.
	locked_display = true
	locked_movement = true

# Hide self
func stop_display() -> void:
	if not locked_display:
		visible = false
		# current_pattern = null # Don't clear last used pattern, but keep it so it doesn't have to be reloaded if the same pattern is displayed again

# Toggle displayed description for patten (Not shown for non-patterns)
func _on_next_desc_pressed() -> void:
	desc_page = (desc_page + 1) % current_pattern.descs.size()
	set_description(current_pattern.descs[desc_page])

# Drag functionality allows the window to be moved around while locked
func _on_drag_button_down() -> void:
	show_above = false # Window will move so mouse is in top left corner this way, which is closer to the button.
	locked_movement = false # Unlock movement temporarily

func _on_drag_button_up() -> void:
	locked_movement = true # Lock movement again

# Close button, for deleting the window once it's been locked. Does nothing if not locked.
func _on_close_pressed() -> void:
	close_if_locked()

# Close if locked. This func should be called to close a popup, as the only unlocked popup is the one managed by Hex_Display.
func close_if_locked() -> void:
	if locked_display:
		queue_free() # Delete self
