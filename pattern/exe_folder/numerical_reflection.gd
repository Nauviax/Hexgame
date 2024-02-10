# Adds the numerical pattern value to the stack
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	hexecutor.stack.push_back(pattern.value)
	return true
