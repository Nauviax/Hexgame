# Takes the inverse cosine of a value with absolute value 1 or less, yielding the angle whose cosine is that value.
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	stack.push_back(acos(num))
	return ""