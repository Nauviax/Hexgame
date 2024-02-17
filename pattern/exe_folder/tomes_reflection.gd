# Pushes the size of the caster's spellbook to the stack.
static var descs = [
	"Returns the size of the caster's spellbook. This is almost always '4'.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(float(hexecutor.caster.node.sb.size()))
	return true