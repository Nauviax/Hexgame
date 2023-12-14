# Swaps the top two iotas on the stack
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	stack.push_back(aa)
	stack.push_back(bb)
	return ""