# READS the element in the stack indexed by the number iota (top of stack) and COPIES it to the top.
# If the number is negative, instead copies the top element of the stack below that many elements.
# 0 refers to the top of stack, which gets removed/consumed by this pattern. Error if 0.
# 1 effectively duplicates the top element to the top.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not a number."
	if num == 0: # Invalid, as the 0th iota is the num we just removed
		stack.push_back(Bad_Iota.new())
		return "Error: 0th index refers to number that was just removed."

	if num < 0: # Negative number, copy top iota below num elements
		if num * -1 >= stack.size(): # Can't push to non-existent index
			stack.push_back(Bad_Iota.new())
			return "Error: Index out of bounds"
		var iota = stack[-1]
		if iota is Array:
			stack.insert(stack.size() - 1 + num, iota.duplicate(true)) # Deep copy
		else:
			stack.insert(stack.size() - 1 + num, iota) # -1 as stack size is larger than normal fisherman's gambit
		
	else: # Positive number, copy element at index to top
		if num > stack.size(): # Can't get non-existent index
			stack.push_back(Bad_Iota.new())
			return "Error: Index out of bounds"
		var iota = stack[stack.size() - num]
		if iota is Array:
			stack.push_back(iota.duplicate(true)) # Deep copy
		else:
			stack.push_back(iota)
	return ""

