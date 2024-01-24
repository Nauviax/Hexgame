# Remove the number (num) at the top of the stack, then remove the num-th element of the list at the top of the stack
# Does nothing if the number is out of bounds
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "list", list))
		return false
	if num > 0 and num < list.size():
		list.pop_at(num) # Only pop if in range
	stack.push_back(list)
	return true