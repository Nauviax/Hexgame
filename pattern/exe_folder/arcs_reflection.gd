# Returns π, the radial representation of half a circle
static var descs = [
	"Returns π, the radial representation of half a circle.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(PI)
	return true