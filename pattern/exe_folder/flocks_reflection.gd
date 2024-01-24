# Pushes the size of the stack to the stack
static var iota_count = 0
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	stack.push_back(float(stack.size()))
	return true