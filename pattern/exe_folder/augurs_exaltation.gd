# If the first argument is True, keeps the second and discards the third; otherwise discards the second and keeps the third.
# (IF)
static var iota_count = 3
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	if aa is bool:
		var bb = stack.pop_back()
		var c = stack.pop_back()
		if aa:
			stack.push_back(bb)
		else:
			stack.push_back(c)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not a bool."
	return ""