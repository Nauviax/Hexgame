# Takes the top two iotas in stack, returns returns b / a (a being the top iota)
# With two vectors, returns the 2D cross product.
#   Obviously a 2D cross product isn't possible
#   This code returns the SIGNED magnitude (z) of the cross product vector, assuming a and b's Z values are 0
#   Can be used to determine whether rotating from b to a moves in a counter clockwise or clockwise direction
#   See "stackoverflow.com/questions/243945"
static var descs = [
	"Given two numbers, returns SECOND / TOP. Given a number (TOP) and a vector (SECOND), divides each vector component by the number.",
	"Given two vectors, returns the 2D cross product, SECOND x TOP. Specifically, returns the Z component of the cross product vector, assuming the Z values of the input vectors are 0. Example: (1,2) x (1,-3) -> (0,0,-5) -> return -5."
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		if aa == 0:
			stack.push_back(Bad_Iota.new(ErrorMM.DIV_BY_ZERO, pattern.name))
			return false
		else:
			stack.push_back(bb / aa)
	elif aa is Vector2 and bb is Vector2:
		stack.push_back((bb.x * aa.y) - (bb.y * aa.x))
	elif aa is float and bb is Vector2:
		if aa == 0:
			stack.push_back(Bad_Iota.new(ErrorMM.DIV_BY_ZERO, pattern.name))
			return false
		else:
			bb.x /= aa
			bb.y /= aa
			stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", aa))
		return false
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name, aa, bb))
		return false
	return true
