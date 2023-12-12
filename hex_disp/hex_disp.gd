extends Control

@onready var main_scene = get_parent()

@onready var stack_label = $Stack
@onready var error_label = $Errors
@onready var raven_label = $Ravenmind
@onready var sb_label = $Spellbook

# Used to keep track of past errors, to create a scrolling history of sorts.
var error_history = ["", "", ""] # Can be made longer for longer history, just check update_clear() also.

# Update all labels
func update_all(hexecutor, error):
	update_stack(hexecutor.stack)
	update_error_label(error)
	update_ravenmind_label(hexecutor.caster.ravenmind)
	update_sb_label(hexecutor.caster)

# Update all labels related to clearing the grid, and clear error history
func update_clear():
	error_history = ["", "", ""]
	update_stack([])
	update_error_label("Grid and Stack cleared!")
	update_ravenmind_label(null)

# Stack label
func update_stack(stack):
	stack_label.text = ""
	var stack_size = stack.size()
	for ii in range(stack_size):
		stack_label.text += str(stack[stack_size - ii - 1]) + "\n"

# Error label
func update_error_label(error):
	error_history.pop_back()
	error_history.push_front(error)
	error_label.text = ""
	for ii in range(error_history.size()):
		error_label.text += " ".repeat(ii) + error_history[ii] + "\n"

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
