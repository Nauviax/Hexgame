# Yanks the iota third from the top of the stack to the top. [c, b, a] becomes [b, a, c]
static var iota_count = 3
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	var c = stack.pop_back()
	stack.push_back(bb)
	stack.push_back(aa)
	stack.push_back(c)
	return ""
	