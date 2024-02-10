# Remove the iota on the end of the list at the top of the stack, and add it to the top of the stack.
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "list", list))
		return false
	var iota = list.pop_back()
	stack.push_back(list)
	stack.push_back(iota)
	return true