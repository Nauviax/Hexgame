# Pushes (0,0)
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(Vector2(0.0, 0.0))
	return ""