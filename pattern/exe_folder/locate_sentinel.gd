# Pushes the caster's sentinel position onto the stack
static var iota_count = 0
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var sentinel_pos = hexecutor.caster.node.sentinel_pos
	if sentinel_pos == null:
		stack.push_back(Bad_Iota.new(ErrorMM.NO_SENTINEL, pattern.name))
		return false
	stack.push_back(sentinel_pos)
	return true
