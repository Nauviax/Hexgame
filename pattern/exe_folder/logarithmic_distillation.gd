# Removes the top number (aa), then takes the logarithm of the next number (bb) using 'a' as its base.
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	var bb = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	stack.push_back(log(bb) / log(aa))
	return ""