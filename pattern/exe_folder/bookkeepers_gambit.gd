# Remove iotas from stack based on value
# Value as a binary number will look something like 10101, where 1 means remove and 0 means keep.
# The rightmost/least significant bit is the top of the stack/last item in list.
static var iota_count = 0
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var value = pattern.value
	# Ensure stack is large enough to remove items
	var count = int(log(value) / log(2)) + 1
	if count > stack.size():
		# Add garbage to BOTTOM of stack until it is large enough
		for ii in range(stack.size(), count):
			stack.push_front(Bad_Iota.new(ErrorMM.WRONG_ARG_COUNT, pattern.name, count, count - stack.size() - 1))
		return false
	
	# Remove the specified items from the stack
	var target = stack.size() - 1 # Start at top of stack
	while value > 0: # More items to remove
		if value % 2 == 1:
			stack.pop_at(target)
		target -= 1
		value = value >> 1
	return true
