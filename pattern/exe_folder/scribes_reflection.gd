# Copy the iota stored in the caster's selected spellbook page and add it to the stack.
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(hexlogic.caster.sb[hexlogic.caster.sb_sel])
	return ""