# Removes the top iota from the stack, and saves it to the caster's ravenmind.
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.caster.node.ravenmind = hexecutor.stack.pop_back()
	return true