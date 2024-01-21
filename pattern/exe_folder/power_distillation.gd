# With two numbers, combines them by raising the b to the power of the a. (a is top of stack)
# With a number and a vector, raises each component of the vector to the number's power.
# With two vectors, combines them into the vector projection of a onto b.
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(bb ** aa)
	elif aa is Vector2 and bb is Vector2:
		stack.push_back(aa.project(bb))
	elif aa is float and bb is Vector2:
		bb.x = bb.x ** aa
		bb.y = bb.y ** aa
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new())
		return "Error: Can't raise a float to the power of an array"
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Attempted to power non-numeric and non-vector values"
	return ""