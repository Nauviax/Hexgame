# Pushes π, the radial representation of half a circle
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(PI)
	return ""