# Returns true if the caster's spellbook can be written to externally, false otherwise.
static var descs = [
	"Returns true if the caster's spellbook can be written to externally, false otherwise.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(hexecutor.caster.writeable)
	return true