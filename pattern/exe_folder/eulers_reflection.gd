# Pushes e, the base of natural logarithms
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(exp(1))
	return ""
