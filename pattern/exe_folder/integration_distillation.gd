# Remove the top of the stack, then add it to the end of the list at the top of the stack.
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var iota = stack.pop_back()
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	list.push_back(iota)
	stack.push_back(list)
	return ""