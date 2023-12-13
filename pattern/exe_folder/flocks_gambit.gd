# Removes num (iota) elements from the stack, then creates a new list with the removed elements.
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	if num > stack.size():
		stack.push_back(Bad_Iota.new())
		return "Error: iota was larger than the stack size"
	var new_list = []
	for ii in range(num):
		new_list.push_front(stack.pop_back()) # push_front so that first iota popped is last in list (Match hexcasting)
	stack.push_back(new_list)
	return ""