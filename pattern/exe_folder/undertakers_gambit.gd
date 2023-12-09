# Copy the top iota of the stack, then put it under the second iota. [b, a] (a is top) becomes [a, b, a].
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	stack.push_back(a)
	stack.push_back(b)
	stack.push_back(a)
	return ""