# Remove the number (num) at the top of the stack, then replace the list at the top with the num-th element of that list.
# Replaces the list with Null if the number is out of bounds.
static var descs = [
	"Given a number (TOP) and a list (SECOND), returns the num-th element of the list. If the number is out of bounds, returns null. (0-indexed)",
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	num = int(num) # Just in case
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "list", list))
		return false
	if num < 0 or num >= len(list):
		stack.push_back(null)
	else:
		stack.push_back(list[num])
	return true