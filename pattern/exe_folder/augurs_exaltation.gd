# If the first argument is True, keeps the second and discards the third; otherwise discards the second and keeps the third.
# (IF)
static var iota_count = 3
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var a = stack.pop_back()
	if a is bool:
		var b = stack.pop_back()
		var c = stack.pop_back()
		if a:
			stack.push_back(b)
		else:
			stack.push_back(c)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not a bool."
	return ""