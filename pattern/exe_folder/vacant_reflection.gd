# Push an empty list to the top of the stack.
static var iota_count = 0
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back([])
	return ""