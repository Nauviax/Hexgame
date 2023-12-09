# Pushes true (Boolean)
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(true)
	return ""