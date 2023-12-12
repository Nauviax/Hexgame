# Copy the iota stored in the caster's selected spellbook page and add it to the stack.
static var iota_count = 0
static func execute(hexlogic, _pattern):
	var iota = hexlogic.caster.sb[hexlogic.caster.sb_sel]
	if iota is Array:
		hexlogic.stack.push_back(iota.duplicate(true)) # Deep copy
	else:
		hexlogic.stack.push_back(iota)
	return ""
