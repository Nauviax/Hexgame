# Takes the top two iotas in stack, returns b - a (a being the top iota)
static var descs = [
	"Given two numbers or vectors, returns SECOND - TOP. Given a number TOP, and a vector SECOND, subtracts TOP from each component of SECOND.",
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(bb - aa)
	elif aa is Vector2 and bb is Vector2:
		bb -= aa
		stack.push_back(bb)
	elif aa is float and bb is Vector2:
		bb.x -= aa
		bb.y -= aa
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", aa))
		return false
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name, aa, bb))
		return false
	return true
