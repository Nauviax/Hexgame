# Takes the top two iotas in stack, returns the sum
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	# Ensure that both values are floats or vectors
	if a is float and b is float:
		stack.push_back(a + b)
	elif a is Vector2 and b is Vector2:
		a += b
		stack.push_back(a)
	elif a is float and b is Vector2:
		b.x += a
		b.y += a
		stack.push_back(b)
	elif a is Vector2 and b is float:
		a.x += b
		a.y += b
		stack.push_back(a)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Attempted to add non-numeric and non-vector value"
	return ""
