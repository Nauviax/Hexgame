# Removes the top number (aa), then takes the logarithm of the next number (bb) using 'a' as its base.
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", aa))
		return false
	var bb = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "number", bb))
		return false
	stack.push_back(log(bb) / log(aa))
	return true