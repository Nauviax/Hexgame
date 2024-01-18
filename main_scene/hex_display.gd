extends Control

@onready var main_scene = get_parent()

@export var stack_path: NodePath # Set in Inspector
@onready var stack_label = get_node(stack_path)

@export var output_path: NodePath # Also set (etc etc)
@onready var output_label = get_node(output_path)

@export var raven_path: NodePath 
@onready var raven_label = get_node(raven_path)

@export var sb_path: NodePath
@onready var sb_label = get_node(sb_path)

@export var border_path: NodePath
@onready var border_label = get_node(border_path)

@export var level_desc_path: NodePath
@onready var level_desc_label = get_node(level_desc_path)

@export var validate_button_path: NodePath
@onready var validate_button = get_node(validate_button_path) # For changing color

# Used to keep track of past outputs, to create a scrolling history of sorts.
var output_history = ["", "", "", "", ""] # Can be made longer for longer history, just check update_clear() also.

# Update border size counter
func update_border_label(prev, current, cast):
	var cast_str = (" + " + str(cast)) if cast != 0 else ""
	border_label.text = "Border score: " + str(prev) + " + " + str(current) + cast_str + " = " + str(prev + current + cast)

# Update all labels related to hexecutor
func update_all_hexy(hexecutor, output):
	update_stack(hexecutor.stack)
	update_output_label(output)
	update_ravenmind_label(hexecutor.caster.node.ravenmind)
	update_sb_label(hexecutor.caster.node)

# Update all labels related to clearing the grid, and clear error history
func update_clear_hexy():
	output_history = ["", "", "", "", ""]
	update_stack([])
	update_output_label("Grid and Stack cleared!")
	update_ravenmind_label(null)

# Stack label
func update_stack(stack):
	stack_label.text = ""
	var stack_size = stack.size()
	for ii in range(stack_size):
		stack_label.text += str(stack[stack_size - ii - 1]) + "\n"

# Output label
func update_output_label(output):
	output_history.pop_back()
	output_history.push_front(output)
	output_label.text = ""
	for ii in range(output_history.size()):
		output_label.text += " ".repeat(ii) + output_history[ii] + "\n"

# Ravenmind label
func update_ravenmind_label(ravenmind):
	if ravenmind == null:
		raven_label.text = ""
	else:
		raven_label.text = "Ravenmind: " + str(ravenmind)

# Spellbook label
func update_sb_label(player):
	sb_label.text = "- Spellbook -\n"
	for ii in range(player.sb.size()):
		if ii == player.sb_sel:
			sb_label.text += "-> "
		else:
			sb_label.text += "   "
		var iota = player.sb[ii]
		sb_label.text += str(ii) + ": " + str(iota if iota != null else "") + "\n"

# Level description label (Called directly by main_scene)
func update_level_desc_label(text):
	level_desc_label.text = text
	# Reset validate button color
	validate_button.modulate = Color(1, 1, 1)

# Handle UI buttons
func _on_level_validate_pressed():
	var validated = main_scene.validate_level()
	print ("Valid level: " + str(validated))
	validate_button.modulate = Color(0, 1, 0) if validated else Color(1, 0, 0)
