# Grabs the element in the stack indexed by the number iota (top of stack) and brings it to the top.
# If the number is negative, instead moves the top element of the stack down that many elements.
# 0 refers to the top of stack, which gets removed/consumed by this pattern. This element is consumed, so do nothing.
# 1 effectively does nothing, as it just brings the top element to the top.
static var descs = [
	"Given a number, REMOVES the iota at that index in the stack and returns it to the top. If negative, instead moves the top iota down 'number' places.",
	"0 refers to the top of the stack, which is the number that gets removed. 1 would just bring the (now) top element to the top. Both of these inputs will do nothing."
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	if num == 0: # 0 refers to the top of stack, which is num. It's consumed, so do nothing.
		return true
	if num < 0: # Negative number, move top iota down
		if num * -1 >= stack.size(): # Can't push to non-existent index
			stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, -stack.size()+1, stack.size(), num))
			return false
		var iota = stack.pop_back()
		stack.insert(stack.size() + num, iota)
	else: # Positive number, move element at index to top
		if num > stack.size(): # Can't get non-existent index
			stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, -stack.size()+1, stack.size(), num))
			return false
		var iota = stack.pop_at(stack.size() - num)
		stack.push_back(iota)
	return true

