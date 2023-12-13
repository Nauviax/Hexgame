# Adds the caster to the stack as an entity iota
static var iota_count = 0
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(hexecutor.caster)
	return ""
