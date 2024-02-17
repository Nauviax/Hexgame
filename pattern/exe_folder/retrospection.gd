# As this is a special pattern, it should never actually be executed.
# If it is, either the player sucks at hexcasting or I suck at coding. 
# (This pattern is used to exit a layer of introspection normally)
static var descs = [
	"Completes an introspection and stops saving future patterns as iotas. Does not end introspection if more than one introspection is active.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	hexecutor.stack.push_back(Bad_Iota.new(ErrorMM.HASTY_RETROSPECTION, pattern.name))
	return false