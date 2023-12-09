# Takes a number (top) and an iota, then pushes a copies of b onto the stack.
# (A count of 2 results in two of the iota on the stack, not three.)
static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not a number."
	var iota = stack.pop_back()
	for ii in range(num):
		stack.push_back(iota)
	return ""

### CLONE MADE ### !!!