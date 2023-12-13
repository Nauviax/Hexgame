# Removes duplicate entries from a list.
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a list"
	var new_list = []
	for iota in list:
		if not iota in new_list:
			new_list.push_back(iota)
	stack.push_back(new_list)
	return ""