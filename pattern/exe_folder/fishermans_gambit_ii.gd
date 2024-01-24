# READS the element in the stack indexed by the number iota (top of stack) and COPIES it to the top.
# If the number is negative, instead copies the top element of the stack below that many elements.
# 0 refers to the top of stack, which gets removed/consumed by this pattern. Return the number to the stack and finish.
# 1 effectively duplicates the top element to the top.
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	if num == 0: # 0 refers to the top of stack, which is num. So give it back and finish.
		stack.push_back(num)
		return true
	if num < 0: # Negative number, copy top iota below num elements
		if num * -1 >= stack.size(): # Can't push to non-existent index
			stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, -stack.size()+1, stack.size(), num))
			return false
		var iota = stack[-1]
		if iota is Array:
			stack.insert(stack.size() - 1 + num, iota.duplicate(true)) # Deep copy
		else:
			stack.insert(stack.size() - 1 + num, iota) # -1 as stack size is larger than normal fisherman's gambit
		
	else: # Positive number, copy element at index to top
		if num > stack.size(): # Can't get non-existent index
			stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, -stack.size()+1, stack.size(), num))
			return false
		var iota = stack[stack.size() - num]
		if iota is Array:
			stack.push_back(iota.duplicate(true)) # Deep copy
		else:
			stack.push_back(iota)
	return true
