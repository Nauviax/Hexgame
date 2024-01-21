# Takes a list from the stack and computes its running sum, for example inputting [1,2,5] would return [1,3,8].
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a list"
	var sum = 0
	var new_list = []
	for ii in list:
		sum += ii
		new_list.append(sum)
	stack.push_back(new_list)
	return ""