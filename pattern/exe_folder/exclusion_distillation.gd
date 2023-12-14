# Returns True if exactly one of the arguments is true; otherwise returns False.
# With two numbers, combines them into a bitset containing every "on" bit present in exactly one of the bitsets.
# With two lists, this creates a SET with every unique element that appears in exactly ONE of the lists.
# (XOR)
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	if aa is bool and bb is bool:
		stack.push_back(aa != bb)
	elif aa is float and bb is float:
		aa = int(aa)
		bb = int(bb)
		stack.push_back(float(aa ^ bb))
	elif aa is Array and bb is Array:
		var result = []
		for iota in aa:
			if (not iota in bb) and (not iota in result):
				result.push_back(iota)
		for iota in bb:
			if (not iota in aa) and (not iota in result):
				result.push_back(iota)
		stack.push_back(result)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not a bool."
	return ""