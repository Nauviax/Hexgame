# Takes a number (top) and an iota, then pushes a copies of b onto the stack.
# (A count of 2 results in two of the iota on the stack, not three.)
# num > 1000 will fail.
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not a number."
	if num > 1000:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was too large. (Shame on you)"
	var iota = stack.pop_back()
	if iota is Array:
		for ii in range(num):
			stack.push_back(iota.duplicate(true)) # Deep copy
	else:
		for ii in range(num):
			stack.push_back(iota)
	return ""

# This pattern has a side effect of creating only duplicates, the original array is lost.
# Shouldn't ever be a problem, but it's worth noting.