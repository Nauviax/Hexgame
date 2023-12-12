# Takes a list from the stack and computes its running product, for example inputting [1,2,5] would return [1,2,10].
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a list"
	var sum = 1
	var new_list = []
	for ii in list:
		sum *= ii
		new_list.append(sum)
	stack.push_back(new_list)
	return ""