# If iota is true, return false. If iota is false, return true.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var iota = stack.pop_back()
	if iota is bool:
		stack.push_back(not iota)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not a bool."
	return ""