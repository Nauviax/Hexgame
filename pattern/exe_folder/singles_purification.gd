# Remove the top iota, then push a list containing only that iota.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var iota = stack.pop_back()
	stack.push_back([iota])
	return ""