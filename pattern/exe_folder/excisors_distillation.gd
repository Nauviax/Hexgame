# Remove the number (num) at the top of the stack, then remove the num-th element of the list at the top of the stack
# Does nothing if the number is out of bounds
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	if num > 0 and num < list.size():
		list.pop_at(num) # Only pop if in range
	stack.push_back(list)
	return ""