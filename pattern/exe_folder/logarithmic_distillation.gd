# Removes the top number (a), then takes the logarithm of the next number (b) using 'a' as its base.
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	if not a is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	var b = stack.pop_back()
	if not b is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	stack.push_back(log(b) / log(a))
	return ""