# Floors the top iota of the stack
# For vectors, floors each element
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	if iota is float:
		stack.push_back(floor(iota))
	elif iota is Vector2:
		stack.push_back(Vector2(floor(iota.x), floor(iota.y)))
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number/vector", iota))
		return false
	return true