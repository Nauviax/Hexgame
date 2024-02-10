# If the first argument is True, keeps the second and discards the third; otherwise discards the second and keeps the third.
# (IF)
static var iota_count = 3
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	if aa is bool:
		var bb = stack.pop_back()
		var cc = stack.pop_back()
		if aa:
			stack.push_back(bb)
		else:
			stack.push_back(cc)
	else:
		stack.push_back(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "bool", aa)
		return false
	return true