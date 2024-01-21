# Takes the top two iotas in stack, returns b - a (a being the top iota)
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
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
		stack.push_back(Bad_Iota.new())
		return "Error: Can't subtract a vector from a float"
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Attempted to add non-numeric and non-vector values"
	return ""
