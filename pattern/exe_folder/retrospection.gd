# As this is a special pattern, it should never actually be executed.
# If it is, either the player sucks at hexcasting or I suck at coding. 
# (This pattern is used to exit a layer of introspection normally)
static var iota_count = 0
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(Bad_Iota.new())
	return "Error: Retrospection was not paired with an earlier Introspection."