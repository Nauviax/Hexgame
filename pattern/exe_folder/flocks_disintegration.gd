# Remove the list at the top of the stack, then push its contents to the stack.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	for ii in list:
		stack.push_back(ii)
	return ""