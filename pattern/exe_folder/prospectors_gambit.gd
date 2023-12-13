# Copy the second-to-last iota of the stack to the top. [b, a] (a is top) becomes [b, a, b].
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	stack.push_back(b)
	stack.push_back(a)
	stack.push_back(b)
	return ""