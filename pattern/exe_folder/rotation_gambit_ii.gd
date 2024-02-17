# Yanks the top iota to the third position. [cc, bb, aa] becomes [aa, cc, bb]
static var descs = [
	"Takes the top iota and brings it to the third position. [third, second, TOP] becomes [TOP, third, second].",
]
static var iota_count = 3
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	var cc = stack.pop_back()
	stack.push_back(aa)
	stack.push_back(cc)
	stack.push_back(bb)
	return true