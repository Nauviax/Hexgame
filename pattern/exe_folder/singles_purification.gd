# Remove the top iota, then push a list containing only that iota.
static var descs = [
	"Removes the top iota, then returns a list containing only that iota.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	stack.push_back([iota])
	return true