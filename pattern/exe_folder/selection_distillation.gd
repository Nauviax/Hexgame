# Remove the number (num) at the top of the stack, then replace the list at the top with the num-th element of that list.
# Replaces the list with Null if the number is out of bounds.
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	num = int(num) # Just in case
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	if num < 0 or num >= len(list):
		stack.push_back(null)
	else:
		stack.push_back(list[num])
	return ""