# Ceilings the top iota of the stack
# For vectors, ceil each element
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var iota = stack.pop_back()
	if iota is float:
		stack.push_back(ceil(iota))
	elif iota is Vector2:
		stack.push_back(Vector2(ceil(iota.x), ceil(iota.y)))
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Invalid iota type"
	return ""