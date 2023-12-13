# If the first argument equals the second (within a small tolerance, 0.0001), return True. Otherwise, return False.
# (~=)
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	if (a is bool and b is bool) or (a is Array and b is Array):
		stack.push_back(a == b)
	elif a is float and b is float:
		stack.push_back(abs(a - b) < 0.0001)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iotas were not supported, or did not match."
	return ""