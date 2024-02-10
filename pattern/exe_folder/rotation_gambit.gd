# Yanks the iota third from the top of the stack to the top. [cc, bb, aa] becomes [bb, aa, cc]
static var iota_count = 3
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	var cc = stack.pop_back()
	stack.push_back(bb)
	stack.push_back(aa)
	stack.push_back(cc)
	return true
	