# Push an empty list to the top of the stack.
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back([])
	return ""