# Copy the iota stored in the caster's selected spellbook page and add it to the stack.
static var iota_count = 0
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var player = hexecutor.caster.node
	var iota = player.sb[player.sb_sel]
	if iota is Array:
		hexecutor.stack.push_back(iota.duplicate(true)) # Deep copy
	else:
		hexecutor.stack.push_back(iota)
	return ""
