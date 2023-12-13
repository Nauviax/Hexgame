# Copy the iota stored in the caster's selected spellbook page and add it to the stack.
static var iota_count = 0
static func execute(hexecutor, _pattern):
	var iota = hexecutor.caster.sb[hexecutor.caster.sb_sel]
	if iota is Array:
		hexecutor.stack.push_back(iota.duplicate(true)) # Deep copy
	else:
		hexecutor.stack.push_back(iota)
	return ""
