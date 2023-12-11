# Pushes the size of the caster's spellbook to the stack.
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(float(hexlogic.caster.sb.size()))
	return ""