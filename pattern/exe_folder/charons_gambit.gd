# Exit the current meta-pattern. Said meta-pattern should set charon_mode to false on exit.
# If not in a meta-pattern, simply end the current hex (Clear grid and stack etc)
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.charon_mode = true
	return ""