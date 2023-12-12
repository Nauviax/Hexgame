# Takes a number from the stack and computes its factorial, for example inputting 4 would return 4*3*2*1=24.
# WARNING: Inputs larger than 21 will be inaccurate due to floating point precision.
# Also worth noting that decimal point will be removed, so 4.5 will be treated as 4.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a list"
	num = int(num) # Round down. Result will still be float due to "if num <=0, return 1.0" code
	if num < 0:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was negative"
	if num > 50: # 22 is inaccurate, 50 is the max. (Please stop)
		stack.push_back(Bad_Iota.new())
		return "Error: iota was too large"
	stack.push_back(factorial(num))
	return ""

# Factorial helper (Recursive)
static func factorial(num):
	if num <= 0:
		return 1.0
	return num * factorial(num - 1)
