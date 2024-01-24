# Remove the top iota, then add it as the first element to the list at the top of the stack.
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "list", list))
		return false
	list.push_front(iota)
	stack.push_back(list)
	return true