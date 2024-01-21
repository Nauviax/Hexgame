# Exit the current meta-pattern. Said meta-pattern should set charon_mode to false on exit.
# If not in a meta-pattern, simply end the current hex (Clear grid and stack etc)
static var iota_count = 0
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.charon_mode = true
	return ""