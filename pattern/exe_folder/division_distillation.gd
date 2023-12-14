# Takes the top two iotas in stack, returns returns b / a (a being the top iota)
# With two vectors, returns the 2D cross product.
#   Obviously a 2D cross product isn't possible
#   This code returns the magnitude (z) of the cross product vector, assuming a and b's Z values are 0
#   Can be used to determine whether rotating from b to a moves in a counter clockwise or clockwise direction
#   See "stackoverflow.com/questions/243945"
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		if aa == 0:
			stack.push_back(Bad_Iota.new())
			return "Error: Attempted to divide by zero (You fool)"
		else:
			stack.push_back(bb / aa)
	elif aa is Vector2 and bb is Vector2:
		stack.push_back((bb.x * aa.y) - (bb.y * aa.x))
	elif aa is float and bb is Vector2:
		if aa == 0:
			stack.push_back(Bad_Iota.new())
			return "Error: Attempted to divide by zero (You fool)"
		else:
			bb.x /= aa
			bb.y /= aa
			stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new())
		return "Error: Can't divide a float by an array"
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Attempted to multiply non-numeric and non-vector value"
	return ""
