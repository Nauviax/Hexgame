# Remove the top iota, then replace the list at the top with the first index of that iota within the list (starting from 0).
# Replaces the list with -1 if the iota doesn't exist in the list.
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "list", list))
		return false
	var index = -1
	for ii in range(list.size()):
		if iota is Pattern: # Special case
			if list[ii] is Pattern and list[ii].name == iota.name:
				index = ii
				break
		else:
			if list[ii] == iota:
				index = ii
				break
	stack.push_back(float(index))
	return true