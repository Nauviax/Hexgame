# Increments the caster's selected spellbook page.
static var iota_count = 0
static func execute(hexecutor, _pattern):
	hexecutor.caster.node.inc_sb() 
	return ""