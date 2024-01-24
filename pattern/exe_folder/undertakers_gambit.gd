# Copy the top iota of the stack, then put it under the second iota. [bb, aa] (aa is top) becomes [aa, bb, aa].
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	stack.push_back(aa)
	stack.push_back(bb)
	stack.push_back(aa)
	return true