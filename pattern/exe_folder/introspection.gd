# Adds a new empty pattern_metalist to the stack, then enables introspection mode.
static var descs = [
	"Begins creating a list of pattern iotas. Until Retrospection is cast, future patterns are appended to this list as iotas rather than being executed.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(Pattern_Metalist.new())
	hexecutor.introspection_depth += 1
	return true