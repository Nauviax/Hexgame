# Removes duplicate entries from a list.
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "list", list))
		return false
	var new_list = []
	for iota in list:
		if not iota in new_list:
			new_list.push_back(iota)
	stack.push_back(new_list)
	return true