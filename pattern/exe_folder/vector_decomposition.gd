# Takes a vector of two values and pushes the contents to the stack.
# For vector [x, y], x is pushed first, then by. (Leaving y on top)
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var vector = stack.pop_back()
	if vector is Vector2:
		stack.push_back(vector.x)
		stack.push_back(vector.y)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "vector", vector))
		return false
	return true
