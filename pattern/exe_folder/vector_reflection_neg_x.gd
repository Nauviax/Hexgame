# Pushes (-1,0)
static var iota_count = 0
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(Vector2(-1.0, 0.0))
	return ""