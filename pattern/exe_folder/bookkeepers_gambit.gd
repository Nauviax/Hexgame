# Remove iotas from stack based on value
# Value as a binary number will look something like 10101, where 1 means remove and 0 means keep.
# The rightmost/least significant bit is the top of the stack/last item in list.
static var iota_count = 0
static func execute(hexlogic, pattern):
	var stack = hexlogic.stack
	var value = pattern.value
	# Ensure stack is large enough to remove items
	var count = int(log(value) / log(2)) + 1
	if count > stack.size():
		# Add garbage to bottom of stack until it is large enough
		for ii in range(stack.size(), count):
			stack.push_front(Bad_Iota.new())
		return "Error: Not enough iotas in stack"
	
	# Remove the specified items from the stack
	var target = stack.size() - 1 # Start at top of stack
	while value > 0: # More items to remove
		if value % 2 == 1:
			stack.pop_at(target)
		target -= 1
		value = value >> 1
	return ""
