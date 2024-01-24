# Duplicates the top two iotas on the stack.
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	stack.push_back(bb)
	stack.push_back(aa)
	if bb is Array:
		stack.push_back(bb.duplicate(true)) # Deep copy
	else:
		stack.push_back(bb)
	if aa is Array:
		stack.push_back(aa.duplicate(true)) # Deep copy
	else:
		stack.push_back(aa)
	return true