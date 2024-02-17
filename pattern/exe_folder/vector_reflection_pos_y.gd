# Pushes (0,1)
static var descs = [
	"Returns a vector pointing down. (0, 1)",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(Vector2(0.0, 1.0))
	return true