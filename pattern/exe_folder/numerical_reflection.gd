# Adds the numerical pattern value to the stack
static var iota_count = 0
static func execute(hexlogic, pattern):
	hexlogic.stack.push_back(pattern.value)
	return ""