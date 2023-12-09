# Takes two numbers and creates a vector. (b, a) where a is on top of the stack.
# This means adding 1 then 2 to stack then executing, (So 2 is on top,) will give (1, 2).
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	# Ensure type
	if a is float and b is float:
		stack.push_back(Vector2(b, a))
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Invalid iota type"
	return ""
