# Duplicates the top two iotas on the stack.
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	stack.push_back(b)
	stack.push_back(a)
	if b is Array:
		stack.push_back(b.duplicate(true)) # Deep copy
	else:
		stack.push_back(b)
	if a is Array:
		stack.push_back(a.duplicate(true)) # Deep copy
	else:
		stack.push_back(a)
	return ""