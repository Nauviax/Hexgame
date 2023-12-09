# Reveals the top value of the stack
static var iota_count = 1
static func execute(hexlogic, _pattern):
	return "Top Iota: " + str(hexlogic.stack[-1])