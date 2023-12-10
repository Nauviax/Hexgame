# Push true if the caster's spellbook can be read from externally, false otherwise.
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(hexlogic.caster.sb_read)
	return ""