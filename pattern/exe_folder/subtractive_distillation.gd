# Takes the top two iotas in stack, returns b - a (a being the top iota)
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	# Ensure that both values are floats or vectors
	if a is float and b is float:
		stack.push_back(b - a)
	elif a is Vector2 and b is Vector2:
		b -= a
		stack.push_back(b)
	elif a is float and b is Vector2:
		b.x -= a
		b.y -= a
		stack.push_back(b)
	elif a is Vector2 and b is float:
		stack.push_back(Bad_Iota.new())
		return "Error: Can't subtract a vector from a float"
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Attempted to add non-numeric and non-vector values"
	return ""
