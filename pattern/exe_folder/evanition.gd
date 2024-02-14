# As this is a special pattern, it should never actually be executed.
# If it is, either the player sucks at hexcasting or I suck at coding.
# (This pattern removes a pattern iota from a metalist normally, does nothing outside of introspection)
static var descs = [
	"Removes a single pattern from the metalist of patterns being drawn, or removes the metalist if it is empty. No effect if not in introspection mode.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	hexecutor.stack.push_back(Bad_Iota.new(ErrorMM.BAD_EVANITION, pattern.name))
	return false