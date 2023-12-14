# Takes the inverse tangent of a Y (aa) and X (bb) value,
# Yielding the angle between the X-axis and a line from the origin to that point.
static var iota_count = 2
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
	var result = atan2(aa, bb)
	stack.push_back(result)
	return ""