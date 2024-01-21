# Reveals the top value of the stack.
# This will save the iota to level_base, then return the value as a string.
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.level_base.revealed_iota = hexecutor.stack[-1]
	return "Top Iota: " + str(hexecutor.stack[-1])