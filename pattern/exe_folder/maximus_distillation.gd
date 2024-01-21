# If the first argument is greater than the second, return True. Otherwise, return False.
# (>)
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	if aa is float and bb is float:
		stack.push_back(aa > bb)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota(s) was not a float."
	return ""