extends Control

@onready var hexlogic = get_parent()

@onready var stack_label = $Stack
@onready var error_label = $Errors
@onready var raven_label = $Ravenmind

# On ready, clear text
func _ready():
	stack_label.text = ""
	error_label.text = ""
	raven_label.text = ""

# Update label so each item in stack is displayed in order right to left, each on a new line
func update_stack(error = ""):
	var stack = hexlogic.stack

	stack_label.text = ""
	var stack_size = stack.size()
	for ii in range(stack_size):
		stack_label.text += str(stack[stack_size - ii - 1]) + "\n"

	error_label.text = error

	var ravenmind = hexlogic.caster.ravenmind
	if ravenmind == null:
		raven_label.text = ""
	else:
		raven_label.text = "Ravenmind: " + str(hexlogic.caster.ravenmind)
