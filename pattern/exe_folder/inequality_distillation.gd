# If the first argument does NOT equals the second (within a small tolerance, 0.0001), return True. Otherwise, return False.
# (!~=)
static var descs = [
	"Given two booleans, returns True if they are not equal, and False otherwise.",
	"Given two numbers, returns True if they are not equal (within a small tolerance, 0.0001), and False otherwise.",
	"Given two lists, returns True if they are not the same, and False otherwise. (By value, not by reference.)"
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	if (aa is bool and bb is bool) or (aa is Array and bb is Array):
		stack.push_back(not (aa == bb))
	elif aa is float and bb is float:
		stack.push_back(not (abs(aa - bb) < 0.0001))
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name, aa, bb))
		return false
	return true