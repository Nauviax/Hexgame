# Takes two numbers and creates a vector. (b, a) where a is on top of the stack.
# This means adding 1 then 2 to stack then executing, (So 2 is on top,) will give (1, 2).
static var descs = [
	"Given two numbers TOP (y) and SECOND (x), returns a vector (SECOND, TOP).",
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
	stack.push_back(Vector2(bb, aa))
	return true
