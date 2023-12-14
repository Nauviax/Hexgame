# Copy the top iota of the stack, then put it under the second iota. [b, a] (a is top) becomes [a, b, a].
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	stack.push_back(aa)
	stack.push_back(bb)
	stack.push_back(aa)
	return ""