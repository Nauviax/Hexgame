# Ceilings the top iota of the stack
# For vectors, ceil each element
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	if iota is float:
		stack.push_back(ceil(iota))
	elif iota is Vector2:
		stack.push_back(Vector2(ceil(iota.x), ceil(iota.y)))
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Invalid iota type"
	return ""