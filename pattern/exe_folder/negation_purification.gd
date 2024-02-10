# If iota is true, return false. If iota is false, return true.
# For numbers, Takes the inversion of the bitset. For example, 0 will become -1, and -100 will become 99.
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	if iota is bool:
		stack.push_back(not iota)
	elif iota is float:
		iota = int(iota)
		stack.push_back(float(~iota))
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number/bool", iota))
		return false
	return true