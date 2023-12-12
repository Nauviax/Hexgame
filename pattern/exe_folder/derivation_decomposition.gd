# Remove the iota on the end of the list at the top of the stack, and add it to the top of the stack.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	var iota = list.pop_back()
	stack.push_back(list)
	stack.push_back(iota)
	return ""