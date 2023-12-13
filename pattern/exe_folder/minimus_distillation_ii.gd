# If the first argument is less than or equal to the second, return True. Otherwise, return False.
# (<=)
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	if a is float and b is float:
		stack.push_back(a <= b)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota(s) was not a float."
	return ""