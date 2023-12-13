# Remove the top iota, then add it as the first element to the list at the top of the stack.
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	list.push_front(iota)
	stack.push_back(list)
	return ""