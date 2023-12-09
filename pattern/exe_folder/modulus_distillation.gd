# Takes the modulus of two numbers. (5 % 3 is 2)
# When applied on vectors, performs the above operation elementwise
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	# Ensure that both values are floats or vectors
	if a is float and b is float:
		stack.push_back(fmod(b, a))
	elif a is Vector2 and b is Vector2:
		b.x = fmod(b.x, a.x)
		b.y = fmod(b.y, a.y)
		stack.push_back(b)
	elif a is float and b is Vector2:
		b.x = fmod(b.x, a)
		b.y = fmod(b.y, a)
		stack.push_back(b)
	elif a is Vector2 and b is float:
		stack.push_back(Bad_Iota.new())
		return "Error: Can't modulus a float by an array"
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Attempted to modulo non-numeric and non-vector values"
	return ""
