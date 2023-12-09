# As this is a special pattern, it should never actually be executed.
# If it is, either the player sucks at hexcasting or I suck at coding. 
# (This pattern is used to exit a layer of introspection normally)
static var iota_count = 0
static func execute(hexlogic, pattern):
	hexlogic.stack.push_back(pattern) # Hasty Retrospection states that the pattern should be added to the stack.
	return "Error: Retrospection was not paired with an earlier Introspection."