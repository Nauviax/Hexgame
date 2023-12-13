# Remove the two numbers at the top of the stack, then take a sublist of the list at the top of the stack between those indices.
# Lower bound inclusive, upper bound exclusive. For example, the 0, 2 sublist of [0, 1, 2, 3, 4] would be [0, 1].
# The top iota, num2, is the upper bound.
# Nums must be in range, though can be ordered backwards to return [].
static var iota_count = 3
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var num2 = stack.pop_back()
	if not num2 is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	num2 = int(num2) # Just in case
	var num1 = stack.pop_back()
	if not num1 is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	num1 = int(num1)
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	# Ensure nums within bounds
	if num1 < 0 or num1 >= list.size() or num2 < 0 or num2 >= list.size():
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not in range"
	# Push the sublist
	var sublist = list.slice(num1, num2)
	stack.push_back(sublist)
	return ""