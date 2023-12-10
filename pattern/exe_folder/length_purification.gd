# Replaces a number with its absolute value, or a vector with its length.
# Additionally, converts boolean values to 0.0 (f) or 1.0 (t).
# Additionallier, converts arrays to their size.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var iota = stack.pop_back()
	if iota is Vector2:
		stack.push_back(iota.length())
	elif iota is float:
		stack.push_back(abs(iota))
	elif iota is bool:
		stack.push_back(1.0 if iota else 0.0)
	elif iota is Array:
		stack.push_back(float(iota.size()))
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Invalid iota type"
	return ""
