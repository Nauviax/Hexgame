# Pushes τ, the radial representation of a complete circle
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(TAU)
	return ""