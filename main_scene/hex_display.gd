extends Control

@onready var main_scene = get_parent()

@export var stack_path: NodePath # Set in Inspector
@onready var stack_label = get_node(stack_path) # $Stack

@export var output_path: NodePath # Also set (etc etc)
@onready var output_label = get_node(output_path) # $Output

@export var raven_path: NodePath 
@onready var raven_label = get_node(raven_path) # $Ravenmind

@export var sb_path: NodePath
@onready var sb_label = get_node(sb_path) # $Spellbook

@export var border_path: NodePath
@onready var border_label = get_node(border_path) # $Stack

# Used to keep track of past outputs, to create a scrolling history of sorts.
var output_history = ["", "", "", "", ""] # Can be made longer for longer history, just check update_clear() also.

# Update border size counter
func update_border_label(prev, current):
	border_label.text = "Border score: " + str(prev) + " + " + str(current) + " = " + str(prev + current)

# Update all labels related to hexecutor
func update_all_hexy(hexecutor, output):
	update_stack(hexecutor.stack)
	update_output_label(output)
	update_ravenmind_label(hexecutor.caster.ravenmind)
	update_sb_label(hexecutor.caster)

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
func update_sb_label(caster):
	sb_label.text = "- Spellbook -\n"
	for ii in range(caster.sb.size()):
		if ii == caster.sb_sel:
			sb_label.text += "-> "
		else:
			sb_label.text += "   "
		var iota = caster.sb[ii]
		sb_label.text += caster.sb_names[ii] + ": " + str(iota if iota != null else "") + "\n"

# Handle UI buttons (Probably to be replaced later) (!!!)
func _on_sb_left_pressed():
	main_scene.spellbook_LR(true)

func _on_sb_right_pressed():
	main_scene.spellbook_LR(false)
