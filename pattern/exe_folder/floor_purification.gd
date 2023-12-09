# Floors the top num of the stack
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var num = stack.pop_back()
	if num is float:
		stack.push_back(floor(num))
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Invalid iota type"
	return ""