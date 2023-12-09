# Adds a new empty pattern_metalist to the stack, then enables introspection mode.
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(Pattern_Metalist.new())
	hexlogic.introspection_depth += 1
	return ""