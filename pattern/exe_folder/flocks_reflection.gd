# Pushes the size of the stack to the stack
static var iota_count = 0
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	stack.push_back(float(stack.size()))
	return ""