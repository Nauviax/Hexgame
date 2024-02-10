# Returns True if at least one of the arguments are True; otherwise returns False.
# With two numbers, combines them into a bitset containing every "on" bit in either bitset.
# With two lists, this creates a SET with every unique element from the two lists.
# (OR)
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	if aa is bool and bb is bool:
		stack.push_back(aa or bb)
	elif aa is float and bb is float:
		aa = int(aa)
		bb = int(bb)
		stack.push_back(float(aa | bb))
	elif aa is Array and bb is Array:
		var result = []
		for iota in aa:
			if not iota in result:
				result.push_back(iota)
		for iota in bb:
			if not iota in result:
				result.push_back(iota)
		stack.push_back(result)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name, aa, bb))
		return false
	return true