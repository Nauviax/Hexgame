# Remove the first iota from the list at the top of the stack, then push that iota to the stack.
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	var iota = list.pop_front()
	stack.push_back(list)
	stack.push_back(iota)
	return ""