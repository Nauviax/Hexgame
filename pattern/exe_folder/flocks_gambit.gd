# Removes num (iota) elements from the stack, then creates a new list with the removed elements.
static var descs = [
	"Given a number, removes that many iotas after the number and returns a list of the removed iotas. The first (TOP) iota removed (Not the initial num) will be the last item in the list.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	if num < 0 or num > stack.size():
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, 0, stack.size(), num))
		return false
	var new_list = []
	for ii in range(num):
		new_list.push_front(stack.pop_back()) # push_front so that first iota popped is last in list (Match hexcasting)
	stack.push_back(new_list)
	return true