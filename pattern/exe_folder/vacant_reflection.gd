# Push an empty list to the top of the stack.
static var descs = [
	"Returns an empty list.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back([])
	return true