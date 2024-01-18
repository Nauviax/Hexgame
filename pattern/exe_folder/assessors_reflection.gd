# Push true if the caster's spellbook can be written to externally, false otherwise.
static var iota_count = 0
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(hexecutor.caster.writeable)
	return ""