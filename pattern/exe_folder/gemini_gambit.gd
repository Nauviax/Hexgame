# Takes a number (top) and an iota, then pushes num copies of iota onto the stack.
# (A count of 2 results in two of the iota on the stack, not three.)
# num > 1000 will fail.
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	if num < 0 or num > 1000:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, 1000, num))
		return false
	var iota = stack.pop_back()
	if iota is Array:
		for ii in range(num):
			stack.push_back(iota.duplicate(true)) # Deep copy
	else:
		for ii in range(num):
			stack.push_back(iota)
	return true

# This pattern has a side effect of creating only duplicates, the original array is lost.
# Shouldn't ever be a problem, but it's worth noting.