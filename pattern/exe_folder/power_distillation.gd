# With two numbers, combines them by raising the b to the power of the a. (a is top of stack)
# With a number and a vector, raises each component of the vector to the number's power.
# With two vectors, combines them into the vector projection of a onto b.
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	# Ensure that both values are floats or vectors
	if a is float and b is float:
		stack.push_back(b ** a)
	elif a is Vector2 and b is Vector2:
		stack.push_back(a.project(b))
	elif a is float and b is Vector2:
		b.x = b.x ** a
		b.y = b.y ** a
		stack.push_back(b)
	elif a is Vector2 and b is float:
		stack.push_back(Bad_Iota.new())
		return "Error: Can't raise a float to the power of an array"
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Attempted to power non-numeric and non-vector values"
	return ""