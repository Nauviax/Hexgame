# Pushes (-1,0)
static var descs = [
	"Returns a vector pointing left. (-1, 0)",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(Vector2(-1.0, 0.0))
	return true