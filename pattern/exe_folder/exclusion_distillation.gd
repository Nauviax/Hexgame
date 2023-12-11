# Returns True if exactly one of the arguments is true; otherwise returns False.
# With two numbers, combines them into a bitset containing every "on" bit present in exactly one of the bitsets.
# With two lists, this creates a SET with every unique element that appears in exactly ONE of the lists.
# (XOR)
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	if a is bool and b is bool:
		stack.push_back(a != b)
	elif a is float and b is float:
		a = int(a)
		b = int(b)
		stack.push_back(float(a ^ b))
	elif a is Array and b is Array:
		var result = []
		for iota in a:
			if (not iota in b) and (not iota in result):
				result.push_back(iota)
		for iota in b:
			if (not iota in a) and (not iota in result):
				result.push_back(iota)
		stack.push_back(result)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not a bool."
	return ""