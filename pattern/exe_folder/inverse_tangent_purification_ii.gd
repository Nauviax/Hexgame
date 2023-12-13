# Takes the inverse tangent of a Y (a) and X (b) value,
# Yielding the angle between the X-axis and a line from the origin to that point.
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var a = stack.pop_back()
	if not a is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	var b = stack.pop_back()
	if not b is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	var result = atan2(a, b)
	stack.push_back(result)
	return ""