# As this is a special pattern, it should never actually be executed.
# If it is, either the player sucks at hexcasting or I suck at coding.
# (This pattern removes a pattern iota from a metalist normally, does nothing outside of introspection)
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(Bad_Iota.new())
	return "Error: Evanition executed outside of Introspection."