# Pushes null
static var descs = [
	"Returns null.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(null)
	return true