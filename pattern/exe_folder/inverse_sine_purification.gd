# Takes the inverse sine of a value with absolute value 1 or less, yielding the angle whose sine is that value.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	stack.push_back(asin(num))
	return ""