# Pushes null
static var iota_count = 0
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(null)
	return ""