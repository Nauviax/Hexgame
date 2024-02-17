# Copy the second-to-last iota of the stack to the top. [b, a] (a is top) becomes [b, a, b].
static var descs = [
	"Copies the second iota in the stack, then pastes it to the top. [second, TOP] becomes [second, TOP, second].",
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	stack.push_back(bb)
	stack.push_back(aa)
	stack.push_back(bb)
	return true