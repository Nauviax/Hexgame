extends Control

@onready var hexlogic = get_parent()

@onready var stack_label = $Stack
@onready var error_label = $Errors
@onready var raven_label = $Ravenmind
@onready var sb_label = $Spellbook

# On ready, clear editor text
func _ready():
	update_all()

# Update all labels
func update_all(error = ""):
	update_stack()
	update_error_label(error)
	update_ravenmind_label()
	update_sb_label()

# Stack label
func update_stack():
	var stack = hexlogic.stack
	stack_label.text = ""
	var stack_size = stack.size()
	for ii in range(stack_size):
		stack_label.text += str(stack[stack_size - ii - 1]) + "\n"

# Error label
func update_error_label(error):
	error_label.text = error

# Ravenmind label
func update_ravenmind_label():
	var ravenmind = hexlogic.caster.ravenmind
	if ravenmind == null:
		raven_label.text = ""
	else:
		raven_label.text = "Ravenmind: " + str(hexlogic.caster.ravenmind)

# Spellbook label
func update_sb_label():
	var caster = hexlogic.caster
	sb_label.text = "- Spellbook -\n"
	for ii in range(caster.sb.size()):
		if ii == caster.sb_sel:
			sb_label.text += "-> "
		else:
			sb_label.text += "   "
		var iota = caster.sb[ii]
		sb_label.text += caster.sb_names[ii] + ": " + str(iota if iota != null else "") + "\n"

# Handle UI buttons (Probably to be replaced later)
func _on_sb_left_pressed():
	hexlogic.caster.dec_sb()
	update_sb_label()

func _on_sb_right_pressed():
	hexlogic.caster.inc_sb()
	update_sb_label()
