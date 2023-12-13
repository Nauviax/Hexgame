# Reveals the top value of the stack
static var iota_count = 1
static func execute(hexecutor, _pattern):
	return "Top Iota: " + str(hexecutor.stack[-1])