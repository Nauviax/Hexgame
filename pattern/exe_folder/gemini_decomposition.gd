# Duplicates the top iota of the stack.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	stack.push_back(a)
	if a is Array:
		stack.push_back(a.duplicate(true)) # Deep copy
	else:
		stack.push_back(a)
	return ""