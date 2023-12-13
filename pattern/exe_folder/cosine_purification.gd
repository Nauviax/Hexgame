# Takes the cosine of an angle in radians, yielding the horizontal component of that angle drawn on a unit circle.
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	stack.push_back(cos(num))
	return ""