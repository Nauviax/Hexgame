# Enables consideration mode.
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.consideration_mode = true
	return true
