# Takes a number from the stack and computes its factorial, for example inputting 4 would return 4*3*2*1=24.
# WARNING: Inputs larger than 21 will be inaccurate due to floating point precision.
# Also worth noting that decimal point will be removed, so 4.5 will be treated as 4.
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	num = int(num) # Round down. Result will still be float due to "if num <=0, return 1.0" code
	if num < 0 or num > 50: # 22 is inaccurate, 50 is the max. (Please stop)
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, 0, 50, num))
		return false
	stack.push_back(factorial(num))
	return true

# Factorial helper (Recursive)
static func factorial(num):
	if num <= 0:
		return 1.0
	return num * factorial(num - 1)
