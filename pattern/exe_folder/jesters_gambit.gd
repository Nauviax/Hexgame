# Swaps the top two iotas on the stack
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	stack.push_back(a)
	stack.push_back(b)
	return ""