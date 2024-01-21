# Duplicates the top iota of the stack.
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	stack.push_back(aa)
	if aa is Array:
		stack.push_back(aa.duplicate(true)) # Deep copy
	else:
		stack.push_back(aa)
	return ""