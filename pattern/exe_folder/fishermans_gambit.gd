# Grabs the element in the stack indexed by the number iota (top of stack) and brings it to the top.
# If the number is negative, instead moves the top element of the stack down that many elements.
# 0 refers to the top of stack, which gets removed/consumed by this pattern. Error if 0.
# 1 effectively does nothing, as it just brings the top element to the top.
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

	if num < 0: # Negative number, move top iota down
		if num * -1 >= stack.size(): # Can't push to non-existent index
			stack.push_back(Bad_Iota.new())
			return "Error: Index out of bounds"
		var iota = stack.pop_back()
		stack.insert(stack.size() + num, iota)
	else: # Positive number, move element at index to top
		if num > stack.size(): # Can't get non-existent index
			stack.push_back(Bad_Iota.new())
			return "Error: Index out of bounds"
		var iota = stack.pop_at(stack.size() - num)
		stack.push_back(iota)
	return ""

