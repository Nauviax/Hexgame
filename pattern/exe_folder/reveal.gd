# Reveals the top value of the stack.
# This will save the iota to level_base, which then gets displayed by hex_display.
static var iota_count = 1
static var is_spell = true # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.level_base.revealed_iota = hexecutor.stack[-1]
	return true