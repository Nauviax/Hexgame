# Remove the top iota from the stack, and save it into the caster's selected spellbook page.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	hexlogic.caster.sb[hexlogic.caster.sb_sel] = hexlogic.stack.pop_back()
	return ""