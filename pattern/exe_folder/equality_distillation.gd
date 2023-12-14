# If the first argument equals the second (within a small tolerance, 0.0001), return True. Otherwise, return False.
# (~=)
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	if (aa is bool and bb is bool) or (aa is Array and bb is Array):
		stack.push_back(aa == bb)
	elif aa is float and bb is float:
		stack.push_back(abs(aa - bb) < 0.0001)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iotas were not supported, or did not match."
	return ""