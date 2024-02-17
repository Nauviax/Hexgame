# Converts iota to boolean
# 0, Null, and empty list (Normal or meta pattern) are false, ANYTHING else is true
static var descs = [
	"Given an iota, converts it to a boolean. 0, Null, and empty list are false, ANYTHING else is true.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	if iota is float:
		stack.push_back(iota != 0)
	elif iota is Array:
		stack.push_back(iota.size() != 0)
	else:
		stack.push_back(iota != null)
	return true