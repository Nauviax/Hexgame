# Copy the iota out of the caster's ravenmind.
static var descs = [
	"Returns a copy of the iota stored in the caster's ravenmind.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(hexecutor.caster.node.ravenmind)
	return true