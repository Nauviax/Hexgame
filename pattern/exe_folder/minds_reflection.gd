# Adds the caster to the stack as an entity iota
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(hexlogic.caster)
	return ""
