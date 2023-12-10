# Removes the top iota from the stack, and saves it to the caster's ravenmind.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	hexlogic.caster.ravenmind = hexlogic.stack.pop_back()
	return ""