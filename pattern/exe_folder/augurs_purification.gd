# Converts iota to boolean
# 0, Null, and empty list (Normal or meta pattern) are false, ANYTHING else is true
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var iota = stack.pop_back()
	if iota is float:
		stack.push_back(iota != 0)
	elif iota is Array:
		stack.push_back(iota.size() != 0) # !!! TEST
	else:
		stack.push_back(iota != null)
	return ""