# Returns True if both arguments are true; otherwise returns False.
# (AND)
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	var b = stack.pop_back()
	if a is bool and b is bool:
		stack.push_back(a and b)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not a bool."
	return ""