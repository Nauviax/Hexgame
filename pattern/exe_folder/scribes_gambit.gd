# Remove the top iota from the stack, and save it into the caster's selected spellbook page.
static var iota_count = 1
static func execute(hexecutor, _pattern):
	hexecutor.caster.sb[hexecutor.caster.sb_sel] = hexecutor.stack.pop_back()
	return ""