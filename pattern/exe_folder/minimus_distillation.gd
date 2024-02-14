# If the first argument is less than the second, return True. Otherwise, return False.
# (<)
static var descs = [
	"Given two numbers, return True if the TOP number is less than the SECOND, and False otherwise.",
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", aa))
		return false
	var bb = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "number", bb))
		return false
	stack.push_back(aa < bb)
	return true