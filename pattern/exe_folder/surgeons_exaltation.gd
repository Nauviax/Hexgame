# Remove the top iota (iota) then a number (num), then set the num-th element of the top list to that iota.
# Does nothing if the number is out of bounds.
static var iota_count = 3
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an array"
	if num > 0 or num < list.size():
		list[num] = iota
	stack.push_back(list)
	return ""
