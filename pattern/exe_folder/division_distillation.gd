# Takes the top two iotas in stack, returns returns b / a (a being the top iota)
# With two vectors, returns the 2D cross product.
#   Obviously a 2D cross product isn't possible
#   This code returns the magnitude (z) of the cross product vector, assuming a and b's Z values are 0
#   Can be used to determine whether rotating from b to a moves in a counter clockwise or clockwise direction
#   See "stackoverflow.com/questions/243945"
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	# Ensure that both values are floats or vectors
	if a is float and b is float:
		if a == 0:
			stack.push_back(Bad_Iota.new())
			return "Error: Attempted to divide by zero (You fool)"
		else:
			stack.push_back(b / a)
	elif a is Vector2 and b is Vector2:
		stack.push_back((b.x * a.y) - (b.y * a.x))
	elif a is float and b is Vector2:
		if a == 0:
			stack.push_back(Bad_Iota.new())
			return "Error: Attempted to divide by zero (You fool)"
		else:
			b.x /= a
			b.y /= a
			stack.push_back(b)
	elif a is Vector2 and b is float:
		stack.push_back(Bad_Iota.new())
		return "Error: Can't divide a float by an array"
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Attempted to multiply non-numeric and non-vector value"
	return ""
