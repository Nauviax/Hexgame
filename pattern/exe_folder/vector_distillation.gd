# Takes two numbers and creates a vector. (b, a) where a is on top of the stack.
# This means adding 1 then 2 to stack then executing, (So 2 is on top,) will give (1, 2).
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	# Ensure type
	if aa is float and bb is float:
		stack.push_back(Vector2(bb, aa))
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Invalid iota type"
	return ""
