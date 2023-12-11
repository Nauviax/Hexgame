# Decrements the caster's selected spellbook page.
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.caster.dec_sb()
	return ""