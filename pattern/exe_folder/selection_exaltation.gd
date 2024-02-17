# Remove the two numbers at the top of the stack, then take a sublist of the list at the top of the stack between those indices.
# Lower bound inclusive, upper bound exclusive. For example, the 0, 2 sublist of [0, 1, 2, 3, 4] would be [0, 1].
# The top iota, num2, is the upper bound.
# Nums must be in range, though can be ordered backwards to return [].
static var descs = [
	"Given two numbers (TOP, SECOND) and a list (THIRD), returns a sublist from the list between the two numbers. Details next page.",
	"Lower bound (SECOND) inclusive, upper bound (TOP) exclusive. If TOP is less than SECOND, returns [].",
]
static var iota_count = 3
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num2 = stack.pop_back()
	if not num2 is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num2))
		return false
	num2 = int(num2) # Just in case
	var num1 = stack.pop_back()
	if not num1 is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "number", num1))
		return false
	num1 = int(num1)
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 2, "list", list))
		return false
	# Ensure nums within bounds
	if num1 < 0 or num1 >= list.size(): # Lower bound (inclusive)
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 1, 0, list.size() - 1, num1))
		return false
	if num2 < 0 or num2 > list.size(): # Upper bound (exclusive)
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, 0, list.size(), num2))
		return false
	# Push the sublist
	var sublist = list.slice(num1, num2)
	stack.push_back(sublist)
	return true