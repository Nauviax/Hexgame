# Yanks the iota third from the top of the stack to the top. [c, b, a] becomes [b, a, c]
static var iota_count = 3
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	var c = stack.pop_back()
	stack.push_back(b)
	stack.push_back(a)
	stack.push_back(c)
	return ""
	