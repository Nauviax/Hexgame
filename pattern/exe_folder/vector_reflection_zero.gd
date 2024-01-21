# Pushes (0,0)
static var iota_count = 0
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(Vector2(0.0, 0.0))
	return ""