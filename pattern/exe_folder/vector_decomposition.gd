# Takes a vector of two values and pushes the contents to the stack.
# For vector [x, y], x is pushed first, then by. (Leaving y on top)
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	if iota is Vector2:
		stack.push_back(iota.x)
		stack.push_back(iota.y)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Invalid iota type"
	return ""
