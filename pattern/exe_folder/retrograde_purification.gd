# Reverse the list at the top of the stack.
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	list.reverse()
	stack.push_back(list)
	return ""
