# Takes a list from the stack and computes its running product, for example inputting [1,2,5] would return [1,2,10].
static var descs = [
	"Given a list of numbers, returns a list of numbers where each element is the PRODUCT of all the elements before it. Example: [1,2,5] would return [1,2,10].",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "list", list))
		return false
	var sum = 1
	var new_list = []
	for ii in list:
		if not ii is float:
			stack.push_back(Bad_Iota.new(ErrorMM.LIST_CONTAINS_INVALID, pattern.name, 0, "float", new_list.size(), ii))
			return false
		sum *= ii
		new_list.append(sum)
	stack.push_back(new_list)
	return true