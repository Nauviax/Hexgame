# Yanks the top iota to the third position. [c, b, a] becomes [a, c, b]
static var iota_count = 3
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	var c = stack.pop_back()
	stack.push_back(a)
	stack.push_back(c)
	stack.push_back(b)
	return ""