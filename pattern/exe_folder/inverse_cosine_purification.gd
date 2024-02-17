# Takes the inverse cosine of a value with absolute value 1 or less, yielding the angle whose cosine is that value.
static var descs = [
	"Given a number, returns the INVERSE COSINE of that number in radians.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	stack.push_back(acos(num))
	return true