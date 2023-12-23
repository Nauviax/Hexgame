# Pushes the caster's sentinel position onto the stack
static var iota_count = 0
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var sentinel_pos = hexecutor.caster.sentinel_pos
	if sentinel_pos == null:
		stack.push_back(Bad_Iota.new())
		return "Error: No sentinel position set"
	stack.push_back(sentinel_pos)
	return ""
